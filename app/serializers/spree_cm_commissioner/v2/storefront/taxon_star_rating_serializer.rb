module SpreeCmCommissioner
  module V2
    module Storefront
      class TaxonStarRatingSerializer < BaseSerializer
        set_type :taxon_star_rating

        attributes :star, :kind

        has_one :taxon, serializer: ::Spree::V2::Storefront::TaxonSerializer
      end
    end
  end
end
