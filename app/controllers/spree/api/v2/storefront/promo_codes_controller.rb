module Spree
  module Api
    module V2
      module Storefront
        class PromoCodesController < ::Spree::Api::V2::ResourceController
          before_action :require_spree_current_user

          def collection
            promotion_ids = fetch_user_specific_promotion_ids(spree_current_user)

            @collection = Spree::Promotion
                          .where(id: promotion_ids)
                          .page(params[:page])
                          .per(params[:per_page])
          end

          private

          def fetch_user_specific_promotion_ids(user)
            Spree::PromotionRuleUser
              .joins(promotion_rule: :promotion)
              .where(user_id: user.id)
              .pluck('spree_promotions.id')
          end

          def collection_serializer
            Spree::Api::V2::Platform::PromotionSerializer
          end

          def model_class
            Spree::Promotion
          end
        end
      end
    end
  end
end
