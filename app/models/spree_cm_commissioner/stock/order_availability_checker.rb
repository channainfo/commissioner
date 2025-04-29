# On top of SpreeCmCommissioner::Stock::AvailabilityChecker, this class does the same thing but in bulk check with redis.
# Which mean, it check basic condition with db first, once pass, it check with redis.
module SpreeCmCommissioner
  module Stock
    class OrderAvailabilityChecker
      attr_reader :order

      def initialize(order)
        @order = order
      end

      def can_supply_all?
        insufficient_stock_lines.empty?
      end

      def insufficient_stock_lines
        cached_inventory_items_group_by_line_item_id.map do |line_item_id, cached_inventory_items|
          line_item = order.line_items.find { |item| item.id == line_item_id }
          line_item unless sufficient_stock_for?(line_item, cached_inventory_items)
        end.compact
      end

      # {
      #   1: [ {inventory_key: "inventory:1", active: true, quantity_available: 5, inventory_item_id: 1, variant_id: 1}],
      #   2: [ {inventory_key: "inventory:2", active: true, quantity_available: 5, inventory_item_id: 2, variant_id: 2}],
      # }
      def cached_inventory_items_group_by_line_item_id
        @cached_inventory_items_group_by_line_item_id ||=
          ::SpreeCmCommissioner::RedisStock::LineItemsCachedInventoryItemsBuilder.new(
            line_item_ids: order.line_items.pluck(:id)
          ).call
      end

      def sufficient_stock_for?(line_item, cached_inventory_items)
        return false unless line_item.variant.available?
        return true unless line_item.variant.should_track_inventory?
        return true if line_item.variant.backorderable?
        return true if line_item.variant.need_confirmation?

        cached_inventory_items.all? { |item| item.active? && item.quantity_available >= line_item.quantity }
      end
    end
  end
end
