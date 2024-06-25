module Spree
  module Api
    module V2
      module Storefront
        class WishedItemsController < Spree::Api::V2::ResourceController
          before_action :require_spree_current_user

          def collection
            @collection ||= spree_current_user.wished_items.where(variant_id: params[:variant_id])
          end

          def model_class
            Spree::WishedItem
          end

          def collection_serializer
            Spree::V2::Storefront::WishedItemSerializer
          end
        end
      end
    end
  end
end
