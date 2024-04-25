require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class Place < ApplicationRecord
    validates :reference, presence: true, unless: -> { Spree::Store.default.code.include?('billing') }
    validates :lat, presence: true, unless: -> { Spree::Store.default.code.include?('billing') }
    validates :lon, presence: true, unless: -> { Spree::Store.default.code.include?('billing') }

    has_many :nearby_places, class_name: 'SpreeCmCommissioner::VendorPlace', dependent: :destroy
    has_many :vendors, through: :nearby_places, source: :vendor, class_name: 'Spree::Vendor'

    def self.ransackable_attributes(auth_object = nil)
      super & %w[name]
    end
  end
end
