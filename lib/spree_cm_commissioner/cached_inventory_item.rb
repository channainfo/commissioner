module SpreeCmCommissioner
  class CachedInventoryItem
    attr_reader :inventory_key, :active, :quantity_available, :inventory_item_id, :variant_id

    def initialize(inventory_key:, active:, quantity_available:, inventory_item_id:, variant_id:)
      @inventory_key = inventory_key
      @active = active
      @quantity_available = quantity_available
      @inventory_item_id = inventory_item_id
      @variant_id = variant_id
    end

    def active?
      active
    end

    def to_h
      instance_variables.each_with_object({}) do |var, hash|
        hash[var.to_s.delete('@').to_sym] = instance_variable_get(var)
      end
    end
  end
end
