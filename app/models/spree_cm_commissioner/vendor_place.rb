require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class VendorPlace < ApplicationRecord
    acts_as_list scope: :vendor

    belongs_to :vendor, class_name: 'Spree::Vendor', dependent: :destroy
    belongs_to :place, class_name: 'SpreeCmCommissioner::Place', dependent: :destroy
  end
end
