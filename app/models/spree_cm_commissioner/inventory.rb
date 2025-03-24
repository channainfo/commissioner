module SpreeCmCommissioner
  class Inventory
    include ActiveModel::Model

    attr_accessor :variant_id, :inventory_date, :quantity_available, :max_capacity, :product_type

    validates :variant_id, presence: true
    validates :quantity_available, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
    validates :max_capacity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  end
end
