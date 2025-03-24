module SpreeCmCommissioner
  module RedisStock
    class InventoryKeyQuantityBuilder
      attr_reader :line_items

      def initialize(line_item_ids)
        @line_items = Spree::LineItem.where(id: line_item_ids)
                                     .includes(variant: [:product, :active_inventory_items])

      end

      # Result: [{inventory_key: "inventory:1", purchase_quantity: 2, quantity_available: 5, inventory_item_id: 1},
      def call
        line_items.map do |line_item|
          inventory_items = inventory_items_for(line_item)
          keys = inventory_items.map { |row| "inventory:#{row.id}" }
          counts = SpreeCmCommissioner.redis_pool.with { |redis| redis.mget(*keys) }

          inventory_items.map.with_index do |inventory_item, i|
            {
              inventory_key: keys[i],
              purchase_quantity: line_item.quantity,
              quantity_available: cache_inventory(keys[i], inventory_item, counts[i]),
              inventory_item_id: inventory_item.id
            }
          end
        end.flatten
      end

      private

      def cache_inventory(key, inventory_item, count_in_redis)
        return count_in_redis.to_i if count_in_redis.present?

        SpreeCmCommissioner.redis_pool.with do |redis|
          redis.set(key, inventory_item.quantity_available, ex: inventory_item.redis_expired_in)
        end
      end

      # TODO: still want to improve this as it fetches all active inventory items
      # We want to fetch exactly the inventory items on line items date range
      def inventory_items_for(line_item)
        scope = line_item.variant.active_inventory_items
        scope = scope.select { |item| line_item.date_range.include?(item.inventory_date) } if line_item.permanent_stock?
        scope
      end
    end
  end
end
