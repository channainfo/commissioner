module Spree
  module Telegram
    class OrdersController < BaseController
      skip_before_action :required_telegram_vendor_user!, only: :show

      def show
        @order = Order.find_by(number: params[:id])
      end

      def reject
        order = order_scope.find_by(number: params[:id])
        raise ActiveRecord::RecordNotFound if order.nil?

        result = Spree::Orders::Cancel.call(order: order, canceler: authorizer_context.user)
        if result.success?
          head :ok
        else
          head :unprocessable_entity
        end
      end

      def approve
        order = order_scope.find_by(number: params[:id])
        raise ActiveRecord::RecordNotFound if order.nil?

        result = Spree::Orders::Approve.call(order: order, approver: authorizer_context.user)
        if result.success?
          head :ok
        else
          head :unprocessable_entity
        end
      end

      def order_scope
        Spree::Order.joins(:line_items).where(line_items: { vendor_id: authorized_vendors.pluck(:id) })
      end
    end
  end
end
