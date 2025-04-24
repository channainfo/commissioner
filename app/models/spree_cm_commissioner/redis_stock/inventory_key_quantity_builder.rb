module SpreeCmCommissioner
  module RedisStock
    class InventoryKeyQuantityBuilder
      def initialize(variant_id:, from_date: nil, to_date: nil)
        @variant_id = variant_id
        @from_date = from_date
        @to_date = to_date
      end

      # Result: [{inventory_key: "inventory:1", purchase_quantity: 2, quantity_available: 5, inventory_item_id: 1},
      def call
        keys = inventory_items.map { |row| "inventory:#{row.id}" }
        counts = SpreeCmCommissioner.redis_pool.with { |redis| redis.mget(*keys) }

        inventory_items.map.with_index do |inventory_item, i|
          {
            inventory_key: keys[i],
            quantity_available: cache_inventory(keys[i], inventory_item, counts[i]),
            inventory_item_id: inventory_item.id
          }
        end
      end

      private

      def cache_inventory(key, inventory_item, count_in_redis)
        return count_in_redis.to_i if count_in_redis.present?

        SpreeCmCommissioner.redis_pool.with do |redis|
          redis.set(key, inventory_item.quantity_available, ex: inventory_item.redis_expired_in)
        end

        inventory_item.quantity_available
      end

      # TODO: still want to improve this as it fetches all active inventory items
      # We want to fetch exactly the inventory items on line items date range
      def inventory_items
        return @inventory_items if defined?(@inventory_items)

        @inventory_items = variant.active_inventory_items
        @inventory_items = inventory_items.select { |item| (from_date...to_date).include?(item.inventory_date) } if variant.permanent_stock?
        @inventory_items
      end

      def variant
        @variant ||= Spree::Variant.find(variant_id)
      end
    end
  end
end
