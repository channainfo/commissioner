module Spree
  module V2
    module Storefront
      class PlaceSerializer < BaseSerializer
        set_type :place

        has_many :vendors
        has_many :nearby_places, serializer: :nearby_place

        attributes :reference, :name, :vicinity, :lat, :lon, :icon, :url, :rating,
                   :formatted_phone_number, :formatted_address, :address_components, :types
      end
    end
  end
end
