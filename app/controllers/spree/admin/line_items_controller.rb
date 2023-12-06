module Spree
  module Admin
    class LineItemsController < Spree::Admin::ResourceController
      before_action :load_data, only: %i[update edit]

      def edit
        return unless @line_item.nil?

        flash[:alert] = Spree.t('notice_messages.line_item_not_found')
        redirect_to cart_admin_order_path(@order)
      end

      def update
        result = update_service.call(line_item: @line_item, line_item_attributes: permitted_resource_params)

        if result.success?
          redirect_to cart_admin_order_path(@order)
        else
          render :edit
        end
      end

      private

      def permitted_resource_params
        params.require(:line_item).permit(:quantity, :from_date, :to_date)
      end

      def update_service
        Spree::Dependencies.line_item_update_service.constantize
      end

      def load_data
        scope = current_store.orders

        @order = scope.find_by(number: params[:order_id])

        @line_item = @order.line_items.find(params[:id])
      end
    end
  end
end
