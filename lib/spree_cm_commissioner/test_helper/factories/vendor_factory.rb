FactoryBot.define do
  factory :cm_vendor, parent: :vendor do
    state { :active }
    default_state_id { Spree::State.first&.id }
    primary_product_type { :ecommerce }

    transient do
      with_logo { false }
    end

    # create a stock_location with the same name as the vendor
    after :build do |vendor, evaluator|
      vendor.default_state_id ||= create(:state).id
      stock_location = Spree::StockLocation.find_by(name: vendor.name) || build(:cm_stock_location, name: vendor.name, state_id: vendor.default_state_id,
                                                                                                    vendor: vendor
      )
      vendor.stock_locations = [stock_location]
    end

    after :create do |vendor, evaluator|
      create(:vendor_logo, viewable: vendor) if evaluator.with_logo
    end

    factory :cm_vendor_with_product do
      transient do
        total_inventory { 10 }
      end

      after :create do |vendor, evaluator|
        if vendor.primary_product_type == :accommodation
          product = create(:cm_accommodation_product, vendor: vendor, total_inventory: evaluator.total_inventory)
        else
          product = create(:product, vendor: vendor, product_type: vendor.primary_product_type)
          product.master.stock_items.first.adjust_count_on_hand(evaluator.total_inventory)
        end

        vendor.update_total_inventory
      end
    end
  end
end
