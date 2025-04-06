module SpreeCmCommissioner
  class EventInventory
    include SpreeCmCommissioner::InventoryFilterable

    attr_reader :variant_ids

    def initialize(variant_ids: [])
      @variant_ids = variant_ids
    end

    def fetch_inventory
      inventory_items
    end

    private

    def inventory_items
      @inventory_items ||= fetch_inventory_items(variant_ids, nil, nil, product_type)
    end

    def product_type
      SpreeCmCommissioner::InventoryItem::PRODUCT_TYPE_EVENT
    end
  end
end
