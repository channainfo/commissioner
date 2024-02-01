module Spree
  module Billing
    class PaymentQrcodesController < Spree::Billing::BaseController
      def destroy
        if @current_vendor.payment_qrcode.destroy
          flash[:success] = Spree.t('notice_messages.qrcode_removed')
        else
          flash[:error] = Spree.t('errors.messages.cannot_remove_qrcode')
        end
        redirect_to edit_billing_vendor_url(@current_vendor)
      end
    end
  end
end
