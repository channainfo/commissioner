require_dependency 'spree_cm_commissioner'
module SpreeCmCommissioner
  class VendorStop < ApplicationRecord
    belongs_to :vendor, class_name: 'Spree::Vendor'
    belongs_to :stop, class_name: 'SpreeCmCommissioner::Place'

    validates :trip_count, numericality: { greater_than_or_equal_to: 0 }
    enum :stop_type, { boarding: 0, drop_off: 1 }
  end
end
