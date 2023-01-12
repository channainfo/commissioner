namespace :spree_cm_commissioner do
  desc "rake spree_cm_commissioner:vendor_updater"
  task vendor_updater: :environment do
    Spree::Vendor.find_each do |vendor|
      SpreeCmCommissioner::VendorJob.perform_later(vendor.id)
    end
  end
end