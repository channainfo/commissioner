module SpreeCmCommissioner
  module Cart
    module DestroyDecorator
      # override to only allow state that can be void.
      # we don't have to void if state is :failed or :invalid.
      def void_payments(order:)
        order.payments.each do |payment|
          payment.void! if payment.can_void?
        end

        success(order: order)
      end
    end
  end
end

unless Spree::Cart::Destroy.included_modules.include?(SpreeCmCommissioner::Cart::DestroyDecorator)
  Spree::Cart::Destroy.prepend(SpreeCmCommissioner::Cart::DestroyDecorator)
end
