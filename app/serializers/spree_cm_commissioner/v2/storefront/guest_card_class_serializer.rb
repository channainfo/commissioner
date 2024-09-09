module SpreeCmCommissioner
  module V2
    module Storefront
      class GuestCardClassSerializer < BaseSerializer
        attributes :id, :name

        belongs_to :taxon, serializer: Spree::V2::Storefront::TaxonSerializer
      end
    end
  end
end
