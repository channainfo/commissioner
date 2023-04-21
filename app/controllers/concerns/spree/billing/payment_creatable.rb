# Extracted from
# Spree::Admin::PaymentsController#create
module Spree
  module Billing
    module PaymentCreatable
      def create
        invoke_callbacks(:create, :before)
        begin
          load_payments
          create_payment
        rescue Spree::Core::GatewayError => e
          invoke_callbacks(:create, :fails)
          flash[:error] = e.message.to_s
          redirect_to new_billing_order_payment_path(@order)
        end
      end

      private

      def create_payment
        if @payments && (saved_payments = @payments.select(&:persisted?)).any?
          invoke_callbacks(:create, :after)

          # Transition order as far as it will go.
          while @order.next; end
          # If "@order.next" didn't trigger payment processing already (e.g. if the order was
          # already complete) then trigger it manually now

          saved_payments.each { |payment| payment.process! if payment.reload.checkout? && @order.complete? }
          flash[:success] = flash_message_for(saved_payments.first, :successfully_created)
          redirect_to spree.billing_order_payments_path(@order)
        else
          @payment ||= @order.payments.build(object_params)
          invoke_callbacks(:create, :fails)
          flash[:error] = Spree.t(:payment_could_not_be_created)
          render :new, status: :unprocessable_entity
        end
      end

      def load_payments
        if @payment_method.store_credit?
          Spree::Dependencies.checkout_add_store_credit_service.constantize.call(order: @order)
          @payments = @order.payments.store_credits.valid
        else
          @payment.attributes = object_params
          if @payment.payment_method.source_required? && params[:card].present? && params[:card] != 'new'
            @payment.source = @payment.payment_method.payment_source_class.find_by(id: params[:card])
          end
          @payment.save!
          @payments = [@payment]
        end
      end

      def object_params
        if params[:payment] && params[:payment_source]
          source_params = params.delete(:payment_source)[params[:payment][:payment_method_id]]
          params[:payment][:source_attributes] = source_params
        end

        params.require(:payment).permit(permitted_payment_attributes)
      end
    end
  end
end
