module SpreeCmCommissioner
  class InventoryUnit < ApplicationRecord
    # Constant
    SERVICE_TYPE_ACCOMODATION = 'accommodation'.freeze
    SERVICE_TYPE_EVENT = 'event'.freeze
    SERVICE_TYPE_BUS = 'bus'.freeze
    SERVICE_TYPES = [
      SERVICE_TYPE_ACCOMODATION,
      SERVICE_TYPE_EVENT,
      SERVICE_TYPE_BUS
    ].freeze

    # Association
    belongs_to :variant, class_name: 'Spree::Variant'

    # Validation
    validates :quantity_available, numericality: { greater_than_or_equal_to: 0 }
    validates :max_capacity, numericality: { greater_than_or_equal_to: 0 }
    validates :inventory_date, presence: true, unless: -> { service_type == SERVICE_TYPE_EVENT }
    validates :variant_id, uniqueness: { scope: :inventory_date, message: ->(object, data) { "The variant is taken on #{object.inventory_date}" } }

    # Scope
    scope :for_service, -> (type) { where(service_type: type) }
  end
end
