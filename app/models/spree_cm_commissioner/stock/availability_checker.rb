module SpreeCmCommissioner
  module Stock
    class AvailabilityChecker
      attr_reader :variant

      def initialize(variant)
        @variant = variant
      end

      def can_supply?(quantity = 1, options = {})
        return false unless variant.available?
        return true unless variant.should_track_inventory?
        return true if variant.backorderable?
        return true if variant.need_confirmation?

        if variant.permanent_stock?
          permanent_stock_variant_available?(quantity, options)
        else
          variant_available?(quantity, options)
        end
      end

      def variant_available?(quantity = 1, options = {})
        SpreeCmCommissioner::VariantAvailability::NonPermanentStockQuery.new(
          variant: variant,
          except_line_item_id: options[:except_line_item_id]
        ).available?(quantity)
      end

      def permanent_stock_variant_available?(quantity = 1, options = {})
        SpreeCmCommissioner::VariantAvailability::PermanentStockQuery.new(
          variant: variant,
          from_date: options[:from_date].to_date,
          to_date: options[:to_date].to_date,
          except_line_item_id: options[:except_line_item_id]
        ).available?(quantity)
      end
    end
  end
end
