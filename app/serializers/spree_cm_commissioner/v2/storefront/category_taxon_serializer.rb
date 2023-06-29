module SpreeCmCommissioner
  module V2
    module Storefront
      class CategoryTaxonSerializer < BaseSerializer
        set_type   :category_taxon

        attributes :name, :pretty_name, :permalink, :seo_title, :description, :meta_title, :meta_description,
                   :meta_keywords, :left, :right, :position, :depth, :updated_at

        has_one :web_banner, serializer: :asset
        has_one :category_icon, serializer: :asset
      end
    end
  end
end
