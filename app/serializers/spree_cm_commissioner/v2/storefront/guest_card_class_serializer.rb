module SpreeCmCommissioner
  module V2
    module Storefront
      class GuestCardClassSerializer < BaseSerializer
        attributes :id, :name, :type

        belongs_to :taxon, serializer: Spree::V2::Storefront::TaxonSerializer

        def type
          @object.class.name.demodulize
        end
      end
    end
  end
end
