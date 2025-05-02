module SpreeCmCommissioner
  module Stock
    class InventoryItemsAdjuster < BaseInteractor
      delegate :variant, :quantity, to: :context

      def call
        variant.inventory_items.active.find_each do |inventory_item|
          inventory_item.adjust_quantity!(quantity)
        end
      end
    end
  end
end
