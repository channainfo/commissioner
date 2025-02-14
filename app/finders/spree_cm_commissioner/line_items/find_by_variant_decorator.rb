module SpreeCmCommissioner
  module LineItems
    module FindByVariantDecorator
      # ovveride
      def execute(order:, variant:, options: {})
        return super unless variant.product.product_type == 'transit'

        order.line_items.detect do |line_item|
          next if options[:date].present? && !(line_item.variant_id == variant.id && line_item.date == options[:date])

          Spree::Dependencies.cart_compare_line_items_service.constantize.call(order: order, line_item: line_item, options: options).value
        end
      end
    end
  end
end

unless Spree::LineItems::FindByVariant.included_modules.include?(SpreeCmCommissioner::LineItems::FindByVariantDecorator)
  Spree::LineItems::FindByVariant.prepend(SpreeCmCommissioner::LineItems::FindByVariantDecorator)
end
