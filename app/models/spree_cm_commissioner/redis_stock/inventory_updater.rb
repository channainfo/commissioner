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

        schedule_sync_inventory(inventory_ids, quantities.map(&:-@))
      end

      def restock!
        keys, quantities, inventory_ids = extract_inventory_data

        raise UnableToRestock unless restock(keys, quantities)

        schedule_sync_inventory(inventory_ids, quantities)
      end

      private

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

      # Data: [{inventory_key: "inventory:1", purchase_quantity: 2, quantity_available: 5, inventory_item_id: 1},]
      def inventory_items
        @inventory_items ||= SpreeCmCommissioner::RedisStock::InventoryKeyQuantityBuilder.new(@line_item_ids).call
      end

      def extract_inventory_data
        keys = inventory_items.pluck(:inventory_key)
        quantities = inventory_items.pluck(:purchase_quantity)
        inventory_ids = inventory_items.pluck(:inventory_item_id)

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

      def schedule_sync_inventory(inventory_ids, quantities)
        SpreeCmCommissioner::InventoryItemSyncerJob.perform_later(inventory_ids:, quantities:)
      end
    end
  end
end
