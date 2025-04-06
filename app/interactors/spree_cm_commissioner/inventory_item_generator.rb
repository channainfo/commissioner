module SpreeCmCommissioner
  class InventoryItemGenerator < BaseInteractor
    def call
      Spree::Variant.find_each do |variant|
        generate_inventory_items(variant)
      end
    end

    private

    def generate_inventory_items(variant)
      case variant.product_type
      when 'event'
        create_event_inventory(variant)
      when 'bus'
        create_bus_inventory(variant)
      when 'accommodation'
        create_accommodation_inventory(variant)
      end
    end

    def create_event_inventory(variant)
      create_inventory_item(variant, nil)
    end

    def create_bus_inventory(variant)
      (Date.tomorrow..Time.zone.today + 90).each do |date|
        create_inventory_item(variant, date)
      end
    end

    def create_accommodation_inventory(variant)
      (Date.tomorrow..Time.zone.today + 365).each do |date|
        create_inventory_item(variant, date)
      end
    end

    def create_inventory_item(variant, inventory_date)
      return if variant.inventory_items.exists?(inventory_date: inventory_date)

      stock = variant.inventory_item_stock
      InventoryItem.create!(
        variant_id: variant.id,
        inventory_date: inventory_date,
        quantity_available: stock[:quantity_available],
        max_capacity: stock[:max_capacity],
        product_type: variant.product_type
      )
    end
  end
end
