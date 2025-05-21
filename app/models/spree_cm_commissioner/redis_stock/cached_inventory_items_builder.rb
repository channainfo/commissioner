module SpreeCmCommissioner
  module RedisStock
    class CachedInventoryItemsBuilder
      attr_reader :inventory_items

      def initialize(inventory_items)
        @inventory_items = inventory_items
      end

      # output: [ CachedInventoryItem(...), CachedInventoryItem(...) ]
      def call
        keys = inventory_items.map { |item| "inventory:#{item.id}" }
        return [] unless keys.any?

        counts = SpreeCmCommissioner.redis_pool.with { |redis| redis.mget(*keys) }
        inventory_items.map.with_index do |inventory_item, i|
          ::SpreeCmCommissioner::CachedInventoryItem.new(
            inventory_key: keys[i],
            active: inventory_item.active?,
            quantity_available: cache_inventory(keys[i], inventory_item, counts[i]),
            inventory_item_id: inventory_item.id,
            variant_id: inventory_item.variant_id
          )
        end
      end

      private

      def cache_inventory(key, inventory_item, count_in_redis)
        return count_in_redis.to_i if count_in_redis.present?
        return inventory_item.quantity_available unless inventory_item.active?

        SpreeCmCommissioner.redis_pool.with do |redis|
          redis.set(key, inventory_item.quantity_available, ex: inventory_item.redis_expired_in)
        end

        inventory_item.quantity_available
      end
    end
  end
end
