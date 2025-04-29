module SpreeCmCommissioner
  module Stock
    class AvailabilityChecker
      attr_reader :variant, :options, :error_message

      def initialize(variant, options = {})
        @variant = variant
        @options = options
        @error_message = nil
      end

      def can_supply?(quantity = 1)
        return false unless variant.available?
        return true unless variant.should_track_inventory?
        return true if variant.backorderable?
        return true if variant.need_confirmation?

        variant_available?(quantity)
      end

      def variant_available?(quantity = 1)
        return false if cached_inventory_items.empty?

        cached_inventory_items.all? do |cached_inventory_item|
          cached_inventory_item.active? && cached_inventory_item.quantity_available >= quantity
        end
      end

      def cached_inventory_items
        return @cached_inventory_items if defined?(@cached_inventory_items)

        if variant.permanent_stock?
          return [] if options[:from_date].blank? || options[:to_date].blank?

          @cached_inventory_items = builder_klass.new(
            variant_id: variant.id,
            from_date: options[:from_date].to_date,
            to_date: options[:to_date].to_date
          ).call
        else
          @cached_inventory_items = builder_klass.new(variant_id: variant.id).call
        end
      end

      def builder_klass
        ::SpreeCmCommissioner::RedisStock::VariantCachedInventoryItemsBuilder
      end
    end
  end
end
