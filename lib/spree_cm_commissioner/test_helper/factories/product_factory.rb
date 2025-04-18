FactoryBot.define do
  factory :cm_product, parent: :base_product do
    vendor { Spree::Vendor.first || create(:cm_vendor) }

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

    factory :route do
      route_type {:automobile}
      product_type { :transit }
      before(:create) do |route, evaluator|
        create(:stock_location) unless Spree::StockLocation.any?
        if route.stores.empty?
          default_store = Spree::Store.default.persisted? ? Spree::Store.default : nil
          store = default_store || create(:store)

          route.stores << [store]
        end
      end
      after(:create) do |route, evaluator|
        trip = route.master
        trip.permanent_stock = 10
        trip.stock_items = [create(:stock_item, variant: trip, stock_location: route.vendor.stock_locations.first)]
        trip.stock_items.first.adjust_count_on_hand(10)

        # option types
        route.option_types << create(:cm_option_type, :origin)
        route.option_types << create(:cm_option_type, :destination)
        route.option_types << create(:cm_option_type, :departure_time)
        route.option_types << create(:cm_option_type, :duration_in_hours)
        route.option_types << create(:cm_option_type, :duration_in_minutes)
        route.option_types << create(:cm_option_type, :allow_seat_selection)
        route.option_types << create(:cm_option_type, :vehicle)
      end
    end

    factory :cm_subscribable_product do
      option_types { [
        create(:cm_option_type, :month),
        create(:cm_option_type, :due_date),
        create(:cm_option_type, :payment_option)
      ] }

      transient do
        month { 6 }
        due_date { 5 }
        payment_option { 'pre-paid' }
      end

      before(:create) do |product, _evaluator|
        product.subscribable = true
      end

      after(:create) do |product, evaluator|
        # p product.option_types
        option_value1 = create(:cm_option_value, presentation: "#{evaluator.month}-months", name: evaluator.month.to_s, option_type: product.option_types[0])
        option_value2 = create(:cm_option_value, presentation: "#{evaluator.due_date} Days", name: evaluator.due_date.to_s, option_type: product.option_types[1])
        option_value3 = create(:cm_option_value, presentation: "#{evaluator.payment_option}", name: evaluator.payment_option.to_s, option_type: product.option_types[2])

        variant = create(:variant, price: product.price, product: product)
        variant.option_values = [option_value1, option_value2, option_value3]
        variant.save!

        variant.stock_items.first.adjust_count_on_hand(10)
      end
    end

    factory :cm_accommodation_product do
      transient do
        total_inventory { 1 }
      end

      before(:create) do |product, _evaluator|
        product.product_type = :accommodation
      end

      after(:create) do |product, evaluator|
        variant = create(:variant, price: product.price, product: product)
        variant.save!

        variant.stock_items.first.adjust_count_on_hand(evaluator.total_inventory)
      end
    end

    factory :cm_bib_number_product, parent: :cm_kyc_product do
      option_types { [
        create(:cm_option_type, :bib_prefix),
      ] }


      transient do
        variant1_bib_prefix { '3KM' }
        variant2_bib_prefix { '5KM' }
        bib_pre_generation_on_create { false }
      end

      before(:create) do |product, evaluator|
        if evaluator.bib_pre_generation_on_create
          product.option_types << create(:cm_option_type, :bib_pre_generation_on_create)
        end
      end

      after(:create) do |product, evaluator|
        option_value1 = create(:cm_option_value, presentation: evaluator.variant1_bib_prefix, name: evaluator.variant1_bib_prefix, option_type: product.option_types[0])
        option_value2 = create(:cm_option_value, presentation: evaluator.variant2_bib_prefix, name: evaluator.variant2_bib_prefix, option_type: product.option_types[0])

        bib_pre_generation_option_value = if evaluator.bib_pre_generation_on_create
          create(:cm_option_value, presentation: 'Yes', name: '1', option_type: product.option_types.find_by(name: 'bib-pre-generation-on-create'))
        end

        variant1 = create(:variant, price: product.price, product: product)
        variant1.option_values = [option_value1]
        variant1.option_values << bib_pre_generation_option_value if evaluator.bib_pre_generation_on_create
        variant1.save!

        variant2 = create(:variant, price: product.price, product: product)
        variant2.option_values = [option_value2]
        variant2.option_values << bib_pre_generation_option_value if evaluator.bib_pre_generation_on_create
        variant2.save!
      end
    end

    factory :cm_kyc_product do
      transient do
        select_fields { [ :guest_name, :guest_gender, :guest_dob]}
      end

      before(:create) do |product, _evaluator|
        fields = product.class::BIT_FIELDS
        product.kyc = _evaluator.select_fields.map { |field| fields[field] }.sum
      end
    end

    factory :cm_event_product do
      taxons { [create(:cm_taxon_event_section, from_date: '2024-02-02'.to_date, to_date: '2024-03-03')] }
    end
  end
end
