FactoryBot.define do
  factory :cm_base_variant, parent: :base_variant do
    transient do
      total_inventory { 10 }
    end

    after :create do |variant, evaluator|
      variant.stock_items.first.adjust_count_on_hand(evaluator.total_inventory)
    end
  end

  factory :cm_variant, parent: :variant do
    product do
      stock_locations = [create(:stock_location)]
      product = create(:product, vendor: create(:active_vendor, stock_locations: stock_locations))
      product
    end
  end
end
