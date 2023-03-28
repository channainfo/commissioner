# Extracted from
# Spree::Admin::PaymentsController#fire
module Spree
  module Admin
    module Merchant
      module PaymentFireable
        def fire
          @payment = @order.payments.find_by!(number: params[:id])

          event = params[:e]
          return unless @payment.payment_source

          # Because we have a transition method also called void, we do this to avoid conflicts.
          event = 'void_transaction' if event == 'void'
          if @payment.send("#{event}!")
            flash[:success] = Spree.t(:payment_updated)
          else
            flash[:error] = Spree.t(:cannot_perform_operation)
          end
        rescue Spree::Core::GatewayError => e
          flash[:error] = e.message.to_s
        ensure
          redirect_to spree.admin_merchant_order_payments_path(@order)
        end
      end
    end
  end
end
