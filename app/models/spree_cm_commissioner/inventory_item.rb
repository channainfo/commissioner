module SpreeCmCommissioner
  class InventoryItem < ApplicationRecord
    include SpreeCmCommissioner::ProductType

    # Constant (deprecated -> we should use [ProductType] instead)
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
    validates :max_capacity, numericality: { greater_than_or_equal_to: 0 } # Originally inventory of each variant.
    validates :inventory_date, presence: true, if: -> { permanent_stock? }
    validates :variant_id, uniqueness: { scope: :inventory_date, message: -> (object, _data) { "The variant is taken on #{object.inventory_date}" } }

    # Scope
    scope :for_product, -> (type) { where(product_type: type) }
    scope :active, -> { where(inventory_date: nil).or(where('inventory_date >= ?', Time.zone.today)) }

    def adjust_quantity!(quantity)
      with_lock do
        self.max_capacity = max_capacity + quantity
        self.quantity_available = quantity_available + quantity

        save!
      end
    end

    def active?
      inventory_date.nil? || inventory_date >= Time.zone.today
    end

    def redis_expired_in
      expired_in = 31_536_000 # 1 year for normal stock
      expired_in = Time.parse(inventory_date.to_s).end_of_day.to_i - Time.zone.now.to_i if inventory_date.present?
      [expired_in, 0].max
    end
  end
end
