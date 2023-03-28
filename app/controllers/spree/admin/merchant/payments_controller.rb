module Spree
  module Admin
    module Merchant
      class PaymentsController < Spree::Admin::Merchant::BaseController
        include Spree::Admin::Merchant::OrderParentsConcern
        include Spree::Admin::Merchant::PaymentCreatable
        include Spree::Admin::Merchant::PaymentFireable

        before_action :load_data

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

          redirect_to new_admin_merchant_order_payment_url(@order) if @payments.empty?
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
          admin_merchant_order_payments_url(options)
        end
      end
    end
  end
end
