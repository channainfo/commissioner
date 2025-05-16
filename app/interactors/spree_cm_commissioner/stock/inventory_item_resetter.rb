module SpreeCmCommissioner
  module Stock
    class InventoryItemResetter < BaseInteractor
      delegate :inventory_item, to: :context

      def call
        max_capacity = variant_total_inventory
        total_purchases = variant_total_purchases
        quantity_available = [max_capacity - total_purchases, 0].max

        updated = inventory_item.update(max_capacity: max_capacity, quantity_available: quantity_available)
        return context.fail!(message: 'Failed to update inventory item', errors: inventory_item.errors.full_messages) unless updated

        clear_inventory_cache
      end

      def variant_total_inventory
        # for shipment, total_on_hand is not orignal stock. shipment does subtract the stock.
        # to get desire result, we need to add to total_purchase.
        if inventory_item.variant.delivery_required?
          inventory_item.variant.total_on_hand.to_i + variant_total_purchases
        else
          inventory_item.variant.total_on_hand.to_i
        end
      end

      def variant_total_purchases
        scope = inventory_item.variant.complete_line_items

        if inventory_item.permanent_stock?
          scope.where('? BETWEEN from_date AND to_date', inventory_item.inventory_date).sum(:quantity).to_i
        else
          scope.sum(:quantity).to_i
        end
      end

      def clear_inventory_cache
        SpreeCmCommissioner.redis_pool.with do |redis|
          redis.del(inventory_item.redis_key)
        end
      end
    end
  end
end
