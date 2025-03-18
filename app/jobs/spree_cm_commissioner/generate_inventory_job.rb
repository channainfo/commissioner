module SpreeCmCommissioner
  class GenerateInventoryJob < ApplicationUniqueJob
    def perform
      Spree::Variant.find_each do |variant|
        case variant.service_type
        when 'event'
          create_event_inventory(variant)
        when 'bus'
          create_bus_inventory(variant)
        when 'accommodation'
          create_accommodation_inventory(variant)
        end
      end
    end

    private

    def create_event_inventory(variant)
      create_inventory_unit(variant, nil)
    end

    def create_bus_inventory(variant)
      (Date.tomorrow..Time.zone.today + 90).each do |date|
        create_inventory_unit(variant, date)
      end
    end

    def create_accommodation_inventory(variant)
      (Date.tomorrow..Time.zone.today + 365).each do |date|
        create_inventory_unit(variant, date)
      end
    end

    def create_inventory_unit(variant, inventory_date)
      return if variant.inventory_units.exists?(inventory_date: inventory_date)

      stock = variant.inventory_unit_stock
      InventoryUnit.create!(
        variant_id: variant.id,
        inventory_date: inventory_date,
        quantity_available: stock[:quantity_available],
        max_capacity: stock[:max_capacity],
        service_type: variant.service_type
      )
    end
  end
end
