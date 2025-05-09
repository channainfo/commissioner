module SpreeCmCommissioner
  module Stock
    class InventoryItemsAdjusterJob < ApplicationUniqueJob
      def perform(variant_id:, quantity:)
        variant = Spree::Variant.find(variant_id)

        SpreeCmCommissioner::Stock::InventoryItemsAdjuster.call(variant: variant, quantity: quantity)
      end
    end
  end
end
