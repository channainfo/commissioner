# filepath: /home/regene/Internship/central_market/commissioner/app/controllers/spree/api/v2/billing/payment_qr_code_controller.rb
module Spree
  module Api
    module V2
      module Billing
        class PaymentQrCodeController < Spree::Api::V2::BaseController
          def checkout
            @order = Spree::Order.find(params[:order_id])
            @create_transaction_params = {
              req_time: Time.zone.now.strftime('%Y%m%d%H%M%S'),
              merchant_id: 'hangmeasmobile',
              tran_id: @order.id,
              amount: @order.total / 4000,
              payment_option: 'abapay_khqr'
            }

            hash_data = @create_transaction_params.slice(
              :req_time,
              :merchant_id,
              :tran_id,
              :amount,
              :payment_option
            ).values.join(' ')

            public_key = 'ecb49bf5-9537-424d-8745-891e47e0813a'

            hash_data = @create_transaction_params.slice(:req_time, :merchant_id, :tran_id, :amount, :payment_option).values.join('')
            hash = Base64.strict_encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha512'), public_key, hash_data))

            @create_transaction_params[:hash] = hash

            form_html = <<-HTML
              <form method="POST" action="https://checkout-sandbox.payway.com.kh/api/payment-gateway/v1/payments/purchase" id="aba_merchant_request">
                <input type="hidden" name="req_time" value="#{@create_transaction_params[:req_time]}">
                <input type="hidden" name="merchant_id" value="#{@create_transaction_params[:merchant_id]}">
                <input type="hidden" name="tran_id" value="#{@create_transaction_params[:tran_id]}">
                <input type="hidden" name="amount" value="#{@create_transaction_params[:amount]}">
                <input type="hidden" name="payment_option" value="#{@create_transaction_params[:payment_option]}">
                <input type="hidden" name="hash" value="#{@create_transaction_params[:hash]}">
                <button type="submit">Submit Payment</button>
              </form>
              <script type="text/javascript">
                document.getElementById('aba_merchant_request').submit();
              </script>
            HTML

            render html: form_html.html_safe, status: :ok
          end

          def success; end
        end
      end
    end
  end
end
