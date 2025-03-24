module SpreeCmCommissioner
  class InventoryItem < ApplicationRecord
    # Constant
    PRODUCT_TYPE_ACCOMMODATION = 'accommodation'.freeze
    PRODUCT_TYPE_EVENT = 'event'.freeze
    PRODUCT_TYPE_BUS = 'bus'.freeze
    PRODUCT_TYPES = [
      PRODUCT_TYPE_ACCOMMODATION,
      PRODUCT_TYPE_EVENT,
      PRODUCT_TYPE_BUS
    ].freeze

    # Association
    belongs_to :variant, class_name: 'Spree::Variant'

    # Validation
    validates :quantity_available, numericality: { greater_than_or_equal_to: 0 }
    validates :max_capacity, numericality: { greater_than_or_equal_to: 0 }
    validates :inventory_date, presence: true, unless: -> { product_type == PRODUCT_TYPE_EVENT }
    validates :variant_id, uniqueness: { scope: :inventory_date, message: ->(object, data) { "The variant is taken on #{object.inventory_date}" } }

    # Scope
    scope :for_product, -> (type) { where(product_type: type) }
  end
end
