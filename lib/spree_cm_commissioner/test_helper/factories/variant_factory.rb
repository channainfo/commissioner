FactoryBot.define do
  factory :cm_variant, class: Spree::Variant do
    price { 19.99 }
    cost_price { 17.00 }
    sku { generate(:sku) }
    weight { generate(:random_float) }
    height { generate(:random_float) }
    width { generate(:random_float) }
    depth { generate(:random_float) }
    is_master { 0 }
    track_inventory { true }
    permanent_stock { 2 }

    product { create(:cm_base_product, with_option_types: true) }

    # ensure stock item will be created for this variant
    before(:create) { create(:cm_stock_location) unless Spree::StockLocation.any? }

    after :build do |variant, evaluator|
      option_types = if variant.product.option_types.empty?
        [ create(:variant_kind_option_type) ]
      else
        variant.product.option_types
      end

      option_types.each do |type|
        variant.option_values << create(:cm_option_value, option_type: type)
      end
    end
  end
end
