FactoryBot.define do
  factory :cm_base_variant, parent: :base_variant do
    is_master { false }
    product { create(:cm_product) }

    transient do
      total_inventory { 10 }
      backorderable { false }
      pregenerate_inventory_items { true }
      pre_inventory_days { nil } # optional for permanent only
    end

    after :create do |variant, evaluator|
      variant.stock_items.first.adjust_count_on_hand(evaluator.total_inventory)
      variant.stock_items.update_all(backorderable: evaluator.backorderable)

      # stock_items is created then enqueue create inventory items job
      # but we want to create inventory items directly in this factory without waiting for job
      if evaluator.pregenerate_inventory_items
        if variant.permanent_stock?
          SpreeCmCommissioner::Stock::PermanentInventoryItemsGenerator.call(variant_ids: [variant.id], pre_inventory_days: evaluator.pre_inventory_days || 3)
        else
          variant.create_default_non_permanent_inventory_item! unless variant.default_inventory_item_exist?
        end
      end
    end
  end

  factory :cm_variant, parent: :cm_base_variant do
    product { create(:cm_product) }

    transient do
      number_of_adults { nil }
      number_of_kids { nil }
      delivery_required { nil }
    end

    after(:create) do |variant, evaluator|
      if evaluator.number_of_adults.present?
        number_of_adults = create(:cm_option_type, :number_of_adults)
        variant.product.option_types << number_of_adults
        variant.option_values << create(:cm_option_value, presentation: evaluator.number_of_adults, name: evaluator.number_of_adults, option_type: number_of_adults)
      end

      if evaluator.number_of_kids.present?
        number_of_kids = create(:cm_option_type, :number_of_kids)
        variant.product.option_types << number_of_kids
        variant.option_values << create(:cm_option_value, presentation: evaluator.number_of_kids, name: evaluator.number_of_kids, option_type: number_of_kids)
      end

      if evaluator.delivery_required == true
        delivery_option = create(:cm_option_type, :delivery_option)
        variant.product.option_types << delivery_option
        variant.option_values << create(:cm_option_value, presentation: 'Delivery', name: 'delivery', option_type: delivery_option)
      end

      variant.save!
    end
  end

  factory :trip, class: Spree::Variant do
    transient do
      departure_time { "10:00" }
      duration { "1" }
      option_values { [] }
      route { }
    end

    before(:create) do |trip, evaluator|
      trip.product = evaluator.route
      trip.option_values = evaluator.option_values
    end

    after(:create) do |trip, evaluator|
      vehicle = SpreeCmCommissioner::Vehicle.find(trip.options.vehicle)
      trip.stock_items = [create(:stock_item, variant: trip, count_on_hand: vehicle.number_of_seats, stock_location: evaluator.product.vendor.stock_locations.first)]
      trip.stock_items.first.adjust_count_on_hand(-10)
      trip.inventory_items.create!(
        max_capacity: vehicle.number_of_seats,
        quantity_available: vehicle.number_of_seats,
        inventory_date: Date.today,
        product_type: trip.product_type)
      SpreeCmCommissioner::Stock::PermanentInventoryItemsGenerator.call(variant_ids: [trip.id])
    end
  end
end
