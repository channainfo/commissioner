require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class Place < ApplicationRecord
    validates :reference, presence: true, unless: -> { Spree::Store.default.code.include?('billing') }
    validates :lat, presence: true, unless: -> { Spree::Store.default.code.include?('billing') }
    validates :lon, presence: true, unless: -> { Spree::Store.default.code.include?('billing') }
    validates :name, presence: true, uniqueness: true, if: -> { Spree::Store.default.code.include?('billing') }

    has_many :nearby_places, class_name: 'SpreeCmCommissioner::VendorPlace', dependent: :destroy
    has_many :vendors, through: :nearby_places, source: :vendor, class_name: 'Spree::Vendor'
    has_many :customers, class_name: 'SpreeCmCommissioner::Customer'

    has_many :product_places, class_name: 'SpreeCmCommissioner::ProductPlace', dependent: :destroy
    has_many :products, through: :product_places

    def self.ransackable_attributes(auth_object = nil)
      super & %w[name code]
    end
  end
end
