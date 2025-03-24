module SpreeCmCommissioner
  class BusInventory
    include SpreeCmCommissioner::InventoryFilterable

    attr_reader :variant_ids, :trip_date

    def initialize(variant_ids: [], trip_date:)
      @variant_ids = variant_ids
      @trip_date = trip_date
    end

    def fetch_inventory
      inventory_items
    end

    private

    def inventory_items
      @inventory_items ||= fetch_inventory_items(variant_ids, trip_date, trip_date.next_day, product_type)
    end

    def product_type
      SpreeCmCommissioner::InventoryItem::PRODUCT_TYPE_BUS
    end
  end
end
