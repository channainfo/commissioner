module Spree
  module Api
    module V2
      module Storefront
        class OrderHistoriesController < ::Spree::Api::V2::ResourceController
          # GET /api/v2/storefront/order_histories
          # For user - no params needed
          # For guest - pass: { "order_tokens[]": [1, 2, 3] }
          def index
            render_serialized_payload do
              serialize_collection(paginated_collection)
            end
          end

          # PATCH /api/v2/storefront/order_histories/:id/archive
          def archive
            order_token = params[:id]
            order = Spree::Order.not_archived.find_by!(token: order_token)

            spree_authorize! :update, order, order_token
            raise CanCan::AccessDenied unless order.payment?

            if order.mark_as_archive
              render_serialized_payload { serialize_resource(order) }
            else
              render_error_payload(order.errors.full_messages.to_sentence)
            end
          end

          private

          def collection
            if spree_current_user.present?
              spree_current_user.orders.payment.not_archived
            else
              order_tokens = Array(params[:order_tokens])
              return Spree::Order.none if order_tokens.empty?

              Spree::Order.payment.not_archived.without_user.where(token: order_tokens)
            end
          end

          def collection_serializer
            Spree::V2::Storefront::CartSerializer
          end

          def resource_serializer
            Spree::V2::Storefront::CartSerializer
          end

          def model_class
            Spree::Order
          end
        end
      end
    end
  end
end
