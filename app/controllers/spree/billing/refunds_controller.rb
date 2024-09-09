module Spree
  module Billing
    class RefundsController < Spree::Admin::RefundsController
      def location_after_save
        billing_order_payments_path(@payment.order)
      end
    end
  end
end
