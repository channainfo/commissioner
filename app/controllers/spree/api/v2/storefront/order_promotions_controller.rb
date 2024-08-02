module Spree
  module Api
    module V2
      module Storefront
        class OrderPromotionsController < Spree::Api::V2::Storefront::UserPromotionController
          before_action :require_spree_current_user
          before_action :set_spree_current_order
          before_action :set_order_token

          def index
            spree_authorize! :update, @spree_current_order, @order_token

            eligible_promotions = spree_current_user.promotions.active.order(:expires_at).filter do |promotion|
              promotion.eligible?(@spree_current_order)
            end

            render_serialized_payload { serialize_collection(eligible_promotions) }
          end

          private

          def set_spree_current_order
            @spree_current_order = spree_current_user.orders.incomplete.order(:created_at).last
          end

          def set_order_token
            @order_token = params[:order_token]
          end

          def collection_serializer
            Spree::V2::Storefront::UserPromotionSerializer
          end

          def serialize_collection(collection)
            collection_serializer.new(
              collection,
              include: [:default_store]
            ).serializable_hash
          end
        end
      end
    end
  end
end
