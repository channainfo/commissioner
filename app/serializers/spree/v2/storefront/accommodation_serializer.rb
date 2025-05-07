module Spree
  module V2
    module Storefront
      class AccommodationSerializer < VendorSerializer
        # set :vendor instead of :accomodation
        # to prevent the serializer from confusion
        # because its model still Spree::Vendor
        set_type :vendor

        attributes :total_inventory, :service_availabilities

        # Deprecated
        attribute :total_booking do |vendor|
          vendor.respond_to?(:total_booking) ? vendor.total_booking : 0
        end

        # Deprecated
        attribute :remaining do |vendor|
          vendor.respond_to?(:remaining) ? vendor.remaining : vendor.total_inventory
        end
      end
    end
  end
end
