module SpreeCmCommissioner
  class NearbyPlacesLoaderJob < ApplicationJob
    def perform(vendor_id)
      vendor = ::Spree::Vendor.find(vendor_id)
      NearbyPlacesLoader.call(vendor: vendor)
    end
  end
end
