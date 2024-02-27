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
      duration { "1" }
      route { }
    end
    before(:create) do |trip, evaluator|
      trip.product = evaluator.route

      trip.option_values = [evaluator.departure_time, evaluator.duration]

    end
    after(:create) do |trip, evaluator|
      trip.stock_items = [create(:stock_item, variant: trip, stock_location: evaluator.product.vendor.stock_locations.first)]
      trip.stock_items.first.adjust_count_on_hand(10)
    end
  end
end
