FactoryBot.define do
  factory :cm_base_product, class: Spree::Product do
    sequence(:name) { |n| "Product ##{n} - #{Kernel.rand(9999)}" }
    description { generate(:random_description) }
    price { 19.99 }
    cost_price { 17.00 }
    sku { generate(:sku) }
    available_on { 1.year.ago }
    deleted_at { nil }
    shipping_category { |r| Spree::ShippingCategory.first || r.association(:shipping_category) }
    product_type { :accommodation }
    vendor { create(:cm_base_vendor, stock_locations: [ create(:stock_location) ]) }

    transient do
      with_variants { false }
      with_option_types { false }
    end

    after :build do |product, evaluator|
      create(:cm_stock_location) unless Spree::StockLocation.any?

      if product.stores.empty?
        default_store = Spree::Store.default.persisted? ? Spree::Store.default : nil
        store = default_store || create(:store)
        product.stores << [ store ]
      end

      product.variants = [
        build(:cm_variant, product: product, permanent_stock: 2)
      ] if evaluator.with_variants

      product.option_types = [
        build(:product_kind_option_type, with_option_values: true),
        build(:variant_kind_option_type, with_option_values: true),
      ] if evaluator.with_option_types
    end

    factory :cm_product do
      tax_category { |r| Spree::TaxCategory.first || r.association(:tax_category) }
    end
  end
end
