module SpreeCmCommissioner
  module V2
    module Storefront
      class VendorIncludeProductSerializer < BaseSerializer
        set_type   :vendor_include_product

        attributes :name, :slug

        has_one :app_promotion_banner, serializer: :vendor_promotion_banner
        has_many :products, serializer: Spree::V2::Storefront::ProductSerializer
      end
    end
  end
end
