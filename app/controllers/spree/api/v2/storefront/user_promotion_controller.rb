module Spree
  module Api
    module V2
      module Storefront
        class UserPromotionController < ::Spree::Api::V2::ResourceController
          before_action :require_spree_current_user

          def collection
            @collection ||= spree_current_user.promotions.order(id: :desc)
          end

          private

          def collection_serializer
            Spree::V2::Storefront::UserPromotionSerializer
          end

          def model_class
            Spree::Promotion
          end
        end
      end
    end
  end
end
