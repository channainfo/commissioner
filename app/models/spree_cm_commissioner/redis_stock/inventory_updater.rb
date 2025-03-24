module SpreeCmCommissioner
  module RedisStock
    class InventoryUpdater
      class UnableToRestock < StandardError; end
      class UnableToUnstock < StandardError; end

      def initialize(line_item_ids)
        @line_item_ids = line_item_ids
      end

      def unstock!
        keys, quantities, inventory_ids = extract_inventory_data

        raise UnableToUnstock, Spree.t(:insufficient_stock_lines_present) unless unstock(keys, quantities)

        inventory_id_and_quantities = inventory_ids.map.with_index do |inventory_id, i|
          { inventory_id: inventory_id, quantity: -quantities[i] }
        end

        schedule_sync_inventory(inventory_id_and_quantities)
      end

      def restock!
        keys, quantities, inventory_ids = extract_inventory_data

        raise UnableToRestock unless restock(keys, quantities)

        inventory_id_and_quantities = inventory_ids.map.with_index do |inventory_id, i|
          { inventory_id: inventory_id, quantity: quantities[i] }
        end

        schedule_sync_inventory(inventory_id_and_quantities)
      end

      private

      def line_items
        @line_items ||= Spree::LineItem.where(id: @line_item_ids)
      end

      def unstock(keys, quantities)
        SpreeCmCommissioner.redis_pool.with do |redis|
          redis.eval(unstock_redis_script, keys: keys, argv: quantities)
        end.positive?
      end

      def restock(keys, quantities)
        SpreeCmCommissioner.redis_pool.with do |redis|
          redis.eval(restock_redis_script, keys: keys, argv: quantities)
        end.positive?
      end

      # Return: [CachedInventoryItem(...), CachedInventoryItem(...)]
      def cached_inventory_items
        @cached_inventory_items ||= SpreeCmCommissioner::RedisStock::LineItemsCachedInventoryItemsBuilder.new(line_item_ids: @line_item_ids).call.values.flatten
      end

      def extract_inventory_data
        keys = []
        quantities = []
        inventory_ids = []

        cached_inventory_items.each do |cached_inventory_item|
          keys << cached_inventory_item.inventory_key
          quantities << line_items.find { |item| item.variant_id == cached_inventory_item.variant_id }.quantity
          inventory_ids << cached_inventory_item.inventory_item_id
        end

        [keys, quantities, inventory_ids]
      end

      def unstock_redis_script
        <<~LUA
          local keys = KEYS
          local quantities = ARGV

          -- Check availability first
          for i, key in ipairs(keys) do
            local current = tonumber(redis.call('GET', key) or 0)
            if current - tonumber(quantities[i]) < 0 then
              return 0
            end
          end

          -- Apply updates
          for i, key in ipairs(keys) do
            redis.call('DECRBY', key, tonumber(quantities[i]))
          end

          return 1
        LUA
      end

      def restock_redis_script
        <<~LUA
          local keys = KEYS
          local quantities = ARGV

          -- Apply restock updates
          for i, key in ipairs(keys) do
            redis.call('INCRBY', key, tonumber(quantities[i]))
          end

          return 1
        LUA
      end

      def schedule_sync_inventory(inventory_id_and_quantities)
        SpreeCmCommissioner::InventoryItemSyncerJob.perform_later(inventory_id_and_quantities:)
      end
    end
  end
end
