module SpreeCmCommissioner
  class VendorJob < ApplicationJob
    def perform(vendor_id)
      vendor = ::Spree::Vendor.find(vendor_id)
      VendorUpdater.call(vendor: vendor)
    end
  end
end
