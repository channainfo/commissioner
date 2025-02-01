module Spree
  module V2
    module Billing
      class TaxonSerializer < Spree::V2::Storefront::BaseSerializer
        attributes :id, :name, :parent_id, :taxonomy_id, :depth, :position, :icon_url, :permalink

        has_many :children, serializer: TaxonSerializer
        has_one :taxonomy, serializer: TaxonomySerializer
      end
    end
  end
end
