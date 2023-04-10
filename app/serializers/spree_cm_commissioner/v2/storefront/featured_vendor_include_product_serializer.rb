module SpreeCmCommissioner
  module V2
    module Storefront
      class FeaturedVendorIncludeProductSerializer < BaseSerializer
        set_type   :featured_vendor_include_product

        attributes :name, :slug, :vendor_type

        has_one :app_promotion_banner, serializer: :vendor_promotion_banner
        has_many :products, serializer: Spree::V2::Storefront::ProductSerializer
      end
    end
  end
end
