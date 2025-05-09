module SpreeCmCommissioner
  module Stock
    class InventoryItemsGenerator < BaseInteractor
      delegate :variant, to: :context

      def call
        if variant.permanent_stock?
          SpreeCmCommissioner::Stock::PermanentInventoryItemsGenerator.call(variant_ids: [variant.id])
        else
          variant.create_default_non_permanent_inventory_item! unless variant.default_inventory_item_exist?
        end
      end
    end
  end
end
