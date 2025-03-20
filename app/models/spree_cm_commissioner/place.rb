require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class Place < ApplicationRecord
    validates :reference, presence: true, if: :validate_reference?
    validates :lat, presence: true, if: :validate_lat?
    validates :lon, presence: true, if: :validate_lon?
    validates :name, presence: true, uniqueness: true, if: -> { Spree::Store.default.code.include?('billing') }

    has_many :nearby_places, class_name: 'SpreeCmCommissioner::VendorPlace', dependent: :destroy
    has_many :vendors, through: :nearby_places, source: :vendor, class_name: 'Spree::Vendor'
    has_many :customers, class_name: 'SpreeCmCommissioner::Customer'

    has_many :product_places, class_name: 'SpreeCmCommissioner::ProductPlace', dependent: :destroy
    has_many :products, through: :product_places
    has_many :children, class_name: 'SpreeCmCommissioner::Place', foreign_key: :parent_id, dependent: :destroy
    belongs_to :parent, class_name: 'SpreeCmCommissioner::Place', optional: true

    has_many :vendor_stops, class_name: 'SpreeCmCommissioner::VendorStop', dependent: :destroy

    def self.ransackable_attributes(auth_object = nil)
      super & %w[name code]
    end

    def validate_reference?
      Spree::Store.default.code.exclude?('billing')
    end

    def validate_lat?
      Spree::Store.default.code.exclude?('billing')
    end

    def validate_lon?
      Spree::Store.default.code.exclude?('billing')
    end
  end
end
