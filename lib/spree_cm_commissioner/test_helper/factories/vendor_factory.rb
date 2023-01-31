FactoryBot.define do
  factory :cm_base_vendor, class: Spree::Vendor do
    name { FFaker::Company.name }
    state { :active }
    slug { 'slug...' }
    about_us { 'about_us...' }
    contact_us { 'contact_us...' }
    notification_email { 'user@cm.com' }
    primary_product_type { :accommodation }
    star_rating { 2 }
    short_description { 'short_description...' }

    transient do
      state_id { Spree::State.first&.id || create(:cm_state).id }

      with_image { false }
      with_photos { false }
      with_logo { false }
      with_promoted_option_types { false }
      with_vendor_kind_option_types { false }
      with_vendor_kind_option_values { false }
    end

    after :build do |vendor, evaluator|
      vendor.stock_locations = [ Spree::StockLocation.find_by(name: vendor.name) || build(:cm_stock_location, name: vendor.name, state_id: evaluator.state_id, vendor: vendor) ]

      vendor.image = build(:cm_vendor_image) if evaluator.with_image
      vendor.photos = [ build(:cm_vendor_photo) ] if evaluator.with_photos
      vendor.logo = build(:cm_vendor_logo) if evaluator.with_logo

      option_types = []
      option_types << build(:vendor_kind_option_type, promoted: false, with_option_values: true) if evaluator.with_promoted_option_types
      option_types << build(:vendor_kind_option_type, promoted: true, with_option_values: true) if evaluator.with_vendor_kind_option_types
      vendor.option_types = option_types

      if evaluator.with_vendor_kind_option_values
        option_types.each do | type |
          vendor.vendor_kind_option_values += type.option_values
        end
      end
    end

    trait :with_all_relationships do
      transient do
        with_image { true }
        with_photos { true }
        with_logo { true }
        with_promoted_option_types { true }
        with_vendor_kind_option_types { true }
        with_vendor_kind_option_values { true }
      end
    end

    factory :cm_vendor_with_products do
      transient do
        products_count { 2 }
      end

      after :create do |vendor, evaluator|
        evaluator.products_count.times do |i|
          create(:cm_product, vendor: vendor, with_variants: true)
        end

        vendor.reload
      end
    end
  end
end
