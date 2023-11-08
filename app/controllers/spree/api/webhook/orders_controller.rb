module Spree
  module Api
    module Webhook
      class OrdersController < BaseController
        def show
          @order = Spree::Order.search_by_qr_data!(params[:id])

          authorized_subscriber! @order

          render json: @order.send(:webhook_payload_body), status: status, content_type: content_type
        end
      end
    end
  end
end
