module SpreeCmCommissioner
  module VariantAvailability
    class NonPermanentStockQuery
      attr_reader :variant, :except_line_item_id, :error_message

      def initialize(variant:, except_line_item_id: nil)
        @variant = variant
        @except_line_item_id = except_line_item_id
        @error_message = nil
      end

      def available?(quantity)
        if @variant.available_quantity >= quantity
          true
        elsif @variant.available_quantity == 1
          @error_message = I18n.t('variant_availability.item_available_instock')
          false
        elsif @variant.available_quantity <= 0
          @error_message = I18n.t('variant_availability.items_out_of_stock')
          false
        else
          @error_message = I18n.t('variant_availability.items_available_instock', available_quantity: @variant.available_quantity)
          false
        end
      end
    end
  end
end
