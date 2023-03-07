require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class VendorPlace < ApplicationRecord
    acts_as_list scope: :vendor

    belongs_to :vendor, class_name: 'Spree::Vendor'
    belongs_to :place, class_name: 'SpreeCmCommissioner::Place'

    accepts_nested_attributes_for :place, allow_destroy: true

    def selected
      vendor.selected_place_references.include?(place.reference)
    end
  end
end
