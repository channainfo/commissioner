module SpreeCmCommissioner
  module VariantAvailability
    class NonPermanentStockQuery
      attr_reader :variant, :except_line_item_id

      def initialize(variant:, except_line_item_id: nil)
        @variant = variant
        @except_line_item_id = except_line_item_id
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
        if reserve_variants.any?
          reserve_variants.all? { |record| record.available_quantity >= quantity }
        else
          variant.stock_items.sum(:count_on_hand) >= quantity
        end
      end
    end
  end
end
