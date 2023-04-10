module SpreeCmCommissioner
  module V2
    module Storefront
      class HomepageDataSerializer < BaseSerializer
        set_type :homepage_data

        has_many :homepage_banners, serializer: :homepage_banner
        has_many :top_categories, serializer: :category_taxon
        has_many :display_products, serializer: :taxon_include_product
        has_many :trending_categories, serializer: :category_taxon
        has_many :featured_brands, serializer: :brand_taxon
        has_many :featured_vendors, serializer: :vendor_include_product
      end
    end
  end
end
