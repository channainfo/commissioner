module Spree
  module Billing
    class PaymentsController < Spree::Billing::BaseController
      include Spree::Billing::OrderParentsConcern
      include Spree::Billing::PaymentCreatable
      include Spree::Billing::PaymentFireable
      include Spree::Admin::OrderConcern

      before_action :load_data
      before_action :set_current_user_instance, except: :index
      before_action :load_order, only: [:show]

      def set_current_user_instance
        @payment.current_user_instance = spree_current_user
      end

      def load_data
        @amount = params[:amount] || @order.total
        @payment_methods = @order.collect_backend_payment_methods

        if @payment&.payment_method
          @payment_method = @payment.payment_method
        else
          @payment_method = @payment_methods.find { |p| p.id == params[:payment][:payment_method_id].to_i } if params[:payment]
          @payment_method ||= @payment_methods.first
        end
      end

      # @overrided

      def index
        @payments = @order.payments.includes(refunds: :reason)
        @refunds = @payments.flat_map(&:refunds)

        redirect_to new_billing_order_payment_url(@order) if @payments.empty?
      end

      def show
        @payment = @object
      end

      def load_resource_instance
        return order.payments.build if new_actions.include?(action)

        order.payments.find_by!(number: params[:id])
      end

      def order
        @order ||= Spree::Order.find_by!(number: params[:order_id])
      end

      def model_class
        Spree::Payment
      end

      def object_name
        'payment'
      end

      def collection_url(options = {})
        billing_order_payments_url(options)
      end
    end
  end
end
