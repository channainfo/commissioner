module SpreeCmCommissioner
  module RedisStock
    class VariantCachedInventoryItemsBuilder
      attr_reader :variant_id, :dates

      def initialize(variant_id:, dates: [])
        @variant_id = variant_id
        @dates = dates
      end

      # output: [ CachedInventoryItem(...), CachedInventoryItem(...) ]
      def call
        ::SpreeCmCommissioner::RedisStock::CachedInventoryItemsBuilder.new(inventory_items).call
      end

      def inventory_items
        variant = Spree::Variant.find(variant_id)

        inventory_items = variant.inventory_items
        inventory_items = inventory_items.where(inventory_date: dates) if variant.permanent_stock?
        inventory_items
      end
    end
  end
end
