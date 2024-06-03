module SpreeCmCommissioner
  module VariantAvailability
    class NonPermanentStockQuery
      attr_reader :variant, :except_line_item_id

      def initialize(variant:, except_line_item_id: nil)
        @variant = variant
        @except_line_item_id = except_line_item_id
      end

      def available?(quantity)
        Spree::LineItem
          .complete
          .select('(SUM(spree_stock_items.count_on_hand) - SUM(spree_line_items.quantity)) AS available_quantity')
          .joins(variant: :stock_items)
          .where(variant_id: variant.id)
          .where.not(id: except_line_item_id)
          .group(:variant_id)
          .all? { |record| record.available_quantity - quantity >= 0 }
      end
    end
  end
end
