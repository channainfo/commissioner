module Spree
  module Billing
    class AdjustmentsController < Spree::Billing::BaseController
      include Spree::Billing::OrderParentsConcern
      belongs_to 'spree/order', find_by: :number

      create.after :update_totals
      destroy.after :update_totals
      update.after :update_totals

      skip_before_action :load_resource, only: %i[toggle_state edit update destroy]
      before_action :set_payable, only: %i[create update]
      before_action :find_adjustment, only: %i[destroy edit update]

      after_action :delete_promotion_from_order, only: [:destroy], if: -> { @adjustment.destroyed? && @adjustment.promotion? }

      def set_payable
        @adjustment.payable = spree_current_user
      end

      def index
        @adjustments = @order.all_adjustments.eligible.order(created_at: :asc)
      end

      private

      # voids
      def update_payments
        @order.payments.map(&:void_transaction!)
        @order.reload.create_default_payment_if_eligble
      end

      def find_adjustment
        # Need to assign to @object here to keep ResourceController happy
        @adjustment = @object = parent.all_adjustments.find(params[:id])
      end

      def update_totals
        @order.reload.update_with_updater!
        update_payments
      end

      # Override method used to create a new instance to correctly
      # associate adjustment with order
      def build_resource
        parent.adjustments.build(order: parent)
      end

      def delete_promotion_from_order
        return if @adjustment.source.nil?

        @order.promotions.delete(@adjustment.source.promotion)
      end

      def location_after_save
        billing_order_payments_url(@order)
      end

      def model_class
        Spree::Adjustment
      end

      def object_name
        'adjustment'
      end

      def collection_url(options = {})
        billing_order_adjustments_url(options)
      end
    end
  end
end
