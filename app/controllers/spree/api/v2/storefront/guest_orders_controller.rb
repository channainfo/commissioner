module Spree
  module Api
    module V2
      module Storefront
        class GuestOrdersController < ::Spree::Api::V2::ResourceController
          def collection
            orders = model_class.where(token: params[:order_tokens])
            apply_filters(orders)
          end

          def show
            order = model_class.find_by(token: params[:id])
            render_serialized_payload { serialize_resource(order) }
          end

          private

          def apply_filters(orders)
            if params[:request_state].present?
              orders.filter_by_request_state
            elsif spree_current_user.present?
              orders.filter_by_match_user_contact(spree_current_user)
            else
              orders.where(state: params[:state])
            end
          end

          def model_class
            Spree::Order
          end

          def collection_serializer
            Spree::V2::Storefront::OrderSerializer
          end

          def resource_serializer
            Spree::V2::Storefront::OrderSerializer
          end
        end
      end
    end
  end
end
