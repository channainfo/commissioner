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
      before_action :verify_event, only: :update

      rescue_from Spree::Core::GatewayError, with: :handle_spree_core_gateway_error
      rescue_from SpreeCmCommissioner::PaymentSourceMissingError, with: :handle_payment_source_missing

      def set_current_user_instance
        @payment.current_user_instance = spree_current_user
      end

      def load_data
        @amount = params[:amount] || @order.total
        @payment_methods = @order.collect_backend_payment_methods
        @penalty_in_day = SpreeCmCommissioner::PenaltyCalculator.calculate_penalty_in_days(Time.zone.now, @order.line_items.first.due_date)

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

      def update
        check_payment_source

        if @payment.send("#{params[:e]}!")
          flash[:success] = Spree.t(:payment_updated)
        else
          flash[:error] = Spree.t(:cannot_perform_operation)
          raise Spree::Core::GatewayError
        end

        redirect_to request.referer || spree.billing_order_payments_path(@order)
      end

      # supported_events is a method from Spree::Billing::PaymentFireable
      def verify_event
        # Because we have a transition method also called void, we do this to avoid conflicts.
        params[:e] = 'void_transaction' if params[:e] == 'void'

        return if supported_events.include?(params[:e])

        flash[:error] = Spree.t(:unsupported_event)
        raise Spree::Core::GatewayError
      end

      def load_resource_instance
        return order.payments.build if new_actions.include?(action)

        order.payments.find_by!(number: params[:id])
      end

      def check_payment_source
        return unless @payment.payment_source.nil? || @payment.payment_source.blank?

        raise SpreeCmCommissioner::PaymentSourceMissingError
      end

      def handle_payment_source_missing
        flash[:error] = Spree.t(:payment_source_missing)

        redirect_to request.referer || spree.billing_order_payments_path(@order)
      end

      def handle_spree_core_gateway_error(error)
        flash[:error] = error.message.to_s

        redirect_to request.referer || spree.billing_order_payments_path(@order)
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
