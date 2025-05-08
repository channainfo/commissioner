module SpreeCmCommissioner
  module Stock
    class InventoryItemsAdjusterJob < ApplicationUniqueJob
      def perform(variant_id:, quantity:)
        variant = Spree::Variant.find(variant_id)

        CmAppLogger.log(label: 'InventoryItemsAdjusterJob', data: { variant_id: variant_id, quantity: quantity }) do
          SpreeCmCommissioner::Stock::InventoryItemsAdjuster.call(variant: variant, quantity: quantity)
        end
      end
    end
  end
end
