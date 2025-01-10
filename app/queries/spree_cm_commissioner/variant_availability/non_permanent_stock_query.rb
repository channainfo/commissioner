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
        reserve_variants =
          Spree::LineItem
          .complete
          .select('(SUM(DISTINCT spree_stock_items.count_on_hand) - SUM(spree_line_items.quantity)) AS available_quantity')
          .joins(variant: :stock_items)
          .where(variant_id: variant.id)
          .where.not(id: except_line_item_id)
          .group(:variant_id)

        # there is a case when variant does not have any purchaces yet, it will return empty & always available true.
        # in this case, we check with stock items directly.

        available_quantity = if reserve_variants.any?
                               reserve_variants.sum(&:available_quantity)
                             else
                               variant.stock_items.sum(:count_on_hand)
                             end
        if available_quantity >= quantity
          true
        elsif available_quantity == 1
          @error_message = I18n.t('variant_availability.item_available_instock')
          false
        elsif available_quantity <= 0
          @error_message = I18n.t('variant_availability.items_out_of_stock')
          false
        else
          @error_message = I18n.t('variant_availability.items_available_instock', available_quantity: available_quantity)
          false
        end
      end
    end
  end
end
