require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class Place < ApplicationRecord
    validates :reference, presence: true, if: :validate_reference?
    validates :lat, presence: true
    validates :lon, presence: true

    has_many :nearby_places, class_name: 'SpreeCmCommissioner::VendorPlace', dependent: :destroy
    has_many :vendors, through: :nearby_places, source: :vendor, class_name: 'Spree::Vendor'
    belongs_to  :location, class_name: 'Spree::State'
  end

  def validate_reference?
    true
  end
end
