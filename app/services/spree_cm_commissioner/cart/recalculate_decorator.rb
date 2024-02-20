module SpreeCmCommissioner
  module Cart
    module RecalculateDecorator
      # override
      def call(order:, line_item:, line_item_created: false, options: {})
        # recaculate is called after update quantity, add or remove line items.
        # order should be reload before recaculate to avoid wrong caculation.
        order.reload

        super
      end
    end
  end
end

unless Spree::Cart::Recalculate.included_modules.include?(SpreeCmCommissioner::Cart::RecalculateDecorator)
  Spree::Cart::Recalculate.prepend(SpreeCmCommissioner::Cart::RecalculateDecorator)
end
