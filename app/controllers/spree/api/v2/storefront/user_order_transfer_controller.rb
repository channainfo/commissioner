module Spree
  module Api
    module V2
      module Storefront
        class UserOrderTransferController < Spree::Api::V2::ResourceController
          before_action :require_spree_current_user

          # POST /api/v2/storefront/user_order_transfer
          def create
            result = SpreeCmCommissioner::UserOrderTransferHandler.call(
              user: spree_current_user,
              order_numbers: params[:order_numbers]
            )

            if result.success?
              render_serialized_payload { serialize_resource(result.successful_orders) }

            else
              render_error_payload(result.message)
            end
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
