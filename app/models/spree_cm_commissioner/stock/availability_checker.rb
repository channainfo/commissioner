module SpreeCmCommissioner
  module Stock
    class AvailabilityChecker
      attr_reader :variant, :error_message

      def initialize(variant)
        @variant = variant
        @error_message = nil
      end

      def can_supply?(quantity = 1, options = {})
        return false unless variant.available?
        return true unless variant.should_track_inventory?
        return true if variant.backorderable?
        return true if variant.need_confirmation?

        # when delivery required, shipment will dynamically add / remove unit from stock item.
        # so we can directly check can_supply with stock items directly.
        return variant.stock_items.sum(:count_on_hand) >= quantity if variant.delivery_required?

        if variant.permanent_stock?
          permanent_stock_variant_available?(quantity, options)
        else
          variant_available?(quantity, options)
        end
      end

      def variant_available?(quantity = 1, _options = {})
        inventory_items = SpreeCmCommissioner::RedisStock::InventoryKeyQuantityBuilder.new(variant_id: variant_id).call
        inventory_items.all? do |inventory_item|
          inventory_item[:quantity_available] >= quantity
        end
      end

      def permanent_stock_variant_available?(quantity = 1, options = {})
        inventory_items = SpreeCmCommissioner::RedisStock::InventoryKeyQuantityBuilder.new(
          variant_id: variant.id,
          from_date: options[:from_date].to_date,
          to_date: options[:to_date].to_date
        ).call

        inventory_items.all? do |inventory_item|
          inventory_item[:quantity_available] >= quantity
        end
      end
    end
  end
end
