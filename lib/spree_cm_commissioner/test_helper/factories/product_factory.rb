FactoryBot.define do
  factory :cm_product, parent: :base_product do
    vendor do
      stock_location = create(:stock_location)
      vendor = create(:active_vendor, stock_locations: [stock_location])
      vendor
    end

    before(:create) do |product|
      create(:stock_location) unless Spree::StockLocation.any?

      if product.stores.empty?
        default_store = Spree::Store.default.persisted? ? Spree::Store.default : nil
        store = default_store || create(:store)

        product.stores << [store]
      end
    end

    factory :cm_product_with_product_kind_option_types do
      before(:create) do |product|
        product_kind_option_type = Spree::OptionType.create(kind: :product, presentation: 'Bathroom & Toiletries', name: 'bathroom-toiletries')
        product_option_values = [
          Spree::OptionValue.create(option_type: product_kind_option_type, presentation: 'Accessible toilet', name: 'accessible-toilet'),
          Spree::OptionValue.create(option_type: product_kind_option_type, presentation: 'Adapted bath', name: 'adapted-bath')
        ]

        normal_option_type = Spree::OptionType.create(kind: :variant, presentation: 'Capacity', name: 'capacity')
        Spree::OptionValue.create(option_type: normal_option_type, presentation: '1 people', name: '1-people')

        variant = build(:master_variant, product: product, option_values: product_option_values)
        product.option_types = product.option_types + [product_kind_option_type, normal_option_type]
        product.master = variant
        product.save!

        product.reload
      end
    end
  end
end
