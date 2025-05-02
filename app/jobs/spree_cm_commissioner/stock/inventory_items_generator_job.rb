module SpreeCmCommissioner
  module Stock
    class InventoryItemsGeneratorJob < ApplicationUniqueJob
      def perform(variant_id:)
        variant = Spree::Variant.find(variant_id)

        SpreeCmCommissioner::Stock::InventoryItemsGenerator.call(variant: variant)
      end
    end
  end
end
