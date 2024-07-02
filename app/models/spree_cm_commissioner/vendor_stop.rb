require_dependency 'spree_cm_commissioner'
module SpreeCmCommissioner
  class VendorStop < ApplicationRecord
    belongs_to :vendor, class_name: 'Spree::Vendor'
    belongs_to :stop, class_name: 'Spree::Taxon'

    enum stop_type: { boarding: 0, drop_off: 1 }
  end
end
