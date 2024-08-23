module SpreeCmCommissioner
  module V2
    module Storefront
      class ProductPlaceSerializer < BaseSerializer
        attributes :type, :checkinable_distance
        has_one :place, serializer: SpreeCmCommissioner::V2::Storefront::PlaceSerializer
      end
    end
  end
end
