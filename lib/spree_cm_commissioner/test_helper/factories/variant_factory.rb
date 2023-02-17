FactoryBot.define do
  factory :cm_variant, parent: :variant do
    permanent_stock { 5 }

    product do
      stock_locations = [create(:stock_location)]
      product = create(:product, vendor: create(:active_vendor, stock_locations: stock_locations))
      product
    end
  end
end
