module SpreeCmCommissioner
  module RedisStock
    class VariantCachedInventoryItemsBuilder
      attr_reader :variant_id, :from_date, :to_date

      def initialize(variant_id:, from_date: nil, to_date: nil)
        @variant_id = variant_id
        @from_date = from_date
        @to_date = to_date
      end

      # output: [ CachedInventoryItem(...), CachedInventoryItem(...) ]
      def call
        ::SpreeCmCommissioner::RedisStock::CachedInventoryItemsBuilder.new(inventory_items).call
      end

      def inventory_items
        variant = Spree::Variant.find(variant_id)

        inventory_items = variant.inventory_items
        inventory_items.where(inventory_date: from_date..to_date) if variant.permanent_stock?

        inventory_items
      end
    end
  end
end
