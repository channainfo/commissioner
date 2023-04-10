module SpreeCmCommissioner
  module V2
    module Storefront
      class TaxonIncludeProductSerializer < BaseSerializer
        set_type   :taxon_include_product

        attributes :name, :description, :permalink, :pretty_name

        has_many :products, serializer: Spree::V2::Storefront::ProductSerializer
      end
    end
  end
end
