namespace :spree_cm_commissioner do
  desc "rake spree_cm_commissioner:vendor_update_price_range"
  task vendor_update_price_range: :environment do
    Spree::Vendor.find_each do |vendor|
      SpreeCmCommissioner::VendorJob.perform_later(vendor.id)
    end
  end
end