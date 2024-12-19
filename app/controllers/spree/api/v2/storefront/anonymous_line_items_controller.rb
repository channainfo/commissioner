module Spree
  module Api
    module V2
      module Storefront
        class AnonymousLineItemsController < Spree::Api::V2::BaseController
          def show
            token = params[:token]
            line_item = line_item_jwt_token(token)
            if line_item
              render_serialized_payload { serialize_resource(line_item) }
            else
              render json: { error: 'Invalid or expired token' }, status: :unauthorized
            end
          end

          def resource_serializer
            Spree::V2::Storefront::LineItemSerializer
          end

          private

          def line_item_jwt_token(token)
            decoded_token = SpreeCmCommissioner::LineItemJwtToken.decode(token)

            line_item_id = decoded_token['line_item_id']

            line_item = Spree::LineItem.find(line_item_id)
            return nil unless line_item

            decoded_token = SpreeCmCommissioner::LineItemJwtToken.decode(token, line_item&.order&.token)
            return nil unless decoded_token

            line_item
          end
        end
      end
    end
  end
end
