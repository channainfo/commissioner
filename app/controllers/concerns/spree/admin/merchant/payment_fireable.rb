# Extracted from
# Spree::Admin::PaymentsController#fire
module Spree
  module Admin
    module Merchant
      module PaymentFireable
        def fire
          fire_action
        rescue Spree::Core::GatewayError => e
          flash[:error] = e.message.to_s
        ensure
          redirect_to spree.admin_merchant_order_payments_path(@order)
        end

        def fire_action
          return unless @payment.payment_source

          event = params[:e]
          event = 'void_transaction' if event == 'void'
          event = supported_events.find { |e| e == event } # safe send()

          raise Spree::Core::GatewayError, Spree.t(:upsupported_payment) if event.blank?

          if @payment.send("#{event}!")
            flash[:success] = Spree.t(:payment_updated)
          else
            flash[:error] = Spree.t(:cannot_perform_operation)
          end
        end

        def supported_events
          %w[void_transaction cancel credit capture]
        end
      end
    end
  end
end
