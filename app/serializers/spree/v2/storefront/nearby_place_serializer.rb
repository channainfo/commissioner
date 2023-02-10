module Spree
  module V2
    module Storefront
      class NearbyPlaceSerializer < BaseSerializer
        set_type :nearby_place

        has_one :vendor
        has_one :place

        attributes :distance, :position
      end
    end
  end
end