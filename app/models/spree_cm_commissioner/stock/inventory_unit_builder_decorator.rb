module SpreeCmCommissioner
  module Stock
    module InventoryUnitBuilderDecorator
      # override
      def units
        @order.line_items.filter_map do |line_item|
          next unless line_item.delivery_required?

          # They go through multiple splits, avoid loading the
          # association to order until needed.
          Spree::InventoryUnit.new(
            pending: true,
            line_item_id: line_item.id,
            variant_id: line_item.variant_id,
            quantity: line_item.quantity,
            order_id: @order.id
          )
        end
      end
    end
  end
end

unless Spree::Stock::InventoryUnitBuilder.included_modules.include?(SpreeCmCommissioner::Stock::InventoryUnitBuilderDecorator)
  Spree::Stock::InventoryUnitBuilder.prepend(SpreeCmCommissioner::Stock::InventoryUnitBuilderDecorator)
end
