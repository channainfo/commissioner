module SpreeCmCommissioner
  module V2
    module Storefront
      class HomepageDataSerializer < BaseSerializer
        set_type :homepage_data

        has_many :homepage_banners, serializer: :homepage_banner
        has_many :top_categories, serializer: :category_taxon
        has_many :diplay_products, serializer: Spree::V2::Storefront::ProductSerializer
        has_many :trending_categories, serializer: :category_taxon
        has_many :featured_brands, serializer: :brand_taxon
        has_many :featured_vendors, serializer: :featured_vendor_include_product
      end
    end
  end
end
