module Spree
  module Api
    module V2
      module Storefront
        class AnonymousOrderController < Spree::Api::V2::BaseController
          def show_anonymous_order
            token = params[:token]
            order = order_jwt_token(token)

            if order
              render_serialized_payload { serialize_resource(order) }
            else
              render json: { error: 'Invalid or expired token' }, status: :unauthorized
            end
          end

          def resource_serializer
            Spree::V2::Storefront::OrderSerializer
          end

          private

          def order_jwt_token(token)
            decoded_token = SpreeCmCommissioner::OrderJwtToken.decode(token)

            order_number = decoded_token['order_number']
            return nil unless order_number

            order = Spree::Order.find_by(number: order_number)
            return nil unless order

            decoded_token = SpreeCmCommissioner::OrderJwtToken.decode(token, order&.token)
            return nil unless decoded_token

            order
          end
        end
      end
    end
  end
end
