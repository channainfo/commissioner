module Spree
  module V2
    module Tenant
      class PlaceSerializer < BaseSerializer
        attributes :reference, :name, :vicinity, :lat, :lon, :icon, :url, :rating,
                   :formatted_phone_number, :formatted_address, :address_components, :types
      end
    end
  end
end
