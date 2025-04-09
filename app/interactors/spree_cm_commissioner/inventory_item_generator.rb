module SpreeCmCommissioner
  class InventoryItemGenerator < BaseInteractor
    delegate :variants, to: :context

    def call
      items = variants || Spree::Variant.all
      items.find_each do |variant|
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
      inventory_item = InventoryItem.create!(
        variant_id: variant.id,
        inventory_date: inventory_date,
        quantity_available: stock[:quantity_available],
        max_capacity: stock[:max_capacity],
        product_type: variant.product_type
      )
      cache_inventory_in_redis(inventory_item)
    end

    def cache_inventory_in_redis(row)
      key = "inventory:#{row.id}"
      expiration_in = calculate_expiration_in_second(row.inventory_date)

      SpreeCmCommissioner.redis_pool.with do |redis|
        redis.set(key, row.quantity_available, ex: expiration_in)
      end
    end

    def calculate_expiration_in_second(inventory_date)
      # 1 year for events
      return 31_536_000 if inventory_date.blank?

      Time.parse(inventory_date.to_s).end_of_day.to_i - Time.now.to_i
    end
  end
end
