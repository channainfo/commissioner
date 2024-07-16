module Spree
  module V2
    module Storefront
      class UserPromotionSerializer < BaseSerializer
        set_type :promotion

        attributes :name, :description, :code, :expires_at, :starts_at, :usage_limit, :promotion_category_id, :created_at, :updated_at,
                   :public_metadata

        has_one :default_store, serializer: Spree::V2::Storefront::StorePromotionSerializer
      end
    end
  end
end
