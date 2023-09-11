require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class Place < ApplicationRecord
    validates :reference, presence: true, if: :validate_reference?
    validates :lat, presence: true, if: :validate_lat?
    validates :lon, presence: true, if: :validate_lon?

    has_many :nearby_places, class_name: 'SpreeCmCommissioner::VendorPlace', dependent: :destroy
    has_many :vendors, through: :nearby_places, source: :vendor, class_name: 'Spree::Vendor'

    def validate_reference?
      true
    end

    def validate_lat?
      true
    end

    def validate_lon?
      true
    end
  end
end
