module Spree
  module Admin
    module Merchant
      class RefundsController < Spree::Admin::RefundsController
        def location_after_save
          admin_merchant_order_payments_path(@payment.order)
        end
      end
    end
  end
end
