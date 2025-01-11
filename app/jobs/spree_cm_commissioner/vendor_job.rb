module SpreeCmCommissioner
  class VendorJob < ApplicationUniqueJob
    def perform(vendor_id)
      vendor = ::Spree::Vendor.find(vendor_id)
      VendorUpdater.call(vendor: vendor)
    end
  end
end
