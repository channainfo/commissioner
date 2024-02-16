FactoryBot.define do
  factory :cm_variant, parent: :variant do
    permanent_stock { 5 }

    product do
      stock_locations = [create(:stock_location)]
      product = create(:product, vendor: create(:active_vendor, stock_locations: stock_locations))
      product
    end
  end

  factory :trip, class: Spree::Variant do
    permanent_stock { 5 }
    transient do
      departure_time { "10:00" }
      duration { "1 hour" }
      vehicle { }
      route { }
    end
    before(:create) do |trip, evaluator|
      trip.product = evaluator.route
      option_value_1 = Spree::OptionValue.find_by( name: "#{evaluator.departure_time}") ||
                        create(:cm_option_value, option_type: evaluator.product.option_types[0],
                                                name:"#{evaluator.departure_time}",
                                                presentation: "#{evaluator.departure_time}")

      option_value_2 = Spree::OptionValue.find_by( name: "#{evaluator.duration}") ||
                        create(:cm_option_value, option_type: evaluator.product.option_types[1],
                                                name:"#{evaluator.duration}",
                                                presentation: "#{evaluator.duration}")

      option_value_3 = Spree::OptionValue.find_by( name: "#{evaluator.vehicle.id}")

      trip.option_values = [option_value_1, option_value_2, option_value_3]

    end
    after(:create) do |trip, evaluator|
      trip.stock_items = [create(:stock_item, variant: trip, stock_location: evaluator.product.vendor.stock_locations.first)]
      trip.stock_items.first.adjust_count_on_hand(10)
    end
  end
end
