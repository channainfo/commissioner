module SpreeCmCommissioner
  module V2
    module Storefront
      class BrandTaxonSerializer < BaseSerializer
        set_type   :brand_taxon

        attributes :name, :pretty_name, :permalink, :seo_title, :description, :meta_title, :meta_description, :meta_keywords,
                   :left, :right, :position, :depth, :lft, :rgt, :custom_redirect_url, :taxon_type, :updated_at

        has_one :brand_logo, serializer: :taxon_brand_logo
      end
    end
  end
end
