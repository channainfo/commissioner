# POST: api/chatrace/orders
#
module Spree
  module Api
    module Chatrace
      class OrdersController < BaseController
        def create
          guest_token = SecureRandom.uuid

          SpreeCmCommissioner::ChatraceOrderCreatorJob.perform_later(
            guest_token: guest_token,
            chatrace_user_id: params[:chatrace_user_id],
            chatrace_api_host: params[:chatrace_api_host],
            chatrace_return_flow_id: params[:chatrace_return_flow_id],
            chatrace_access_token: params[:chatrace_access_token],
            order_params: params.permit(
              :order_email,
              :order_phone_number,
              :variant_id,
              *SpreeCmCommissioner::Guest.csv_importable_columns
            )
          )

          render_serialized_payload do
            { queue_guest_token: guest_token }
          end
        end
      end
    end
  end
end
