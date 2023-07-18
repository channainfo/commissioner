FactoryBot.define do
  factory :cm_vendor, parent: :vendor do
    state { :active }

    transient do
      state_id { Spree::State.first&.id }
      with_logo { false }
    end

    # create a stock_location with the same name as the vendor
    after :build do |vendor, evaluator|
      state_id ||= create(:state).id
      stock_location = Spree::StockLocation.find_by(name: vendor.name) || build(:cm_stock_location, name: vendor.name, state_id: evaluator.state_id,
                                                                                                    vendor: vendor
      )
      vendor.stock_locations = [stock_location]
    end

    after :create do |vendor, evaluator|
      create(:vendor_logo, viewable: vendor) if evaluator.with_logo
    end

    factory :cm_vendor_with_product do
      transient do
        permanent_stock { 10 }
        product_type { :accommodation }
      end

      after :create do |vendor, evaluator|
        product = create(:product, vendor: vendor, product_type: evaluator.product_type)

        variant = product.master
        variant.permanent_stock = evaluator.permanent_stock
        variant.save

        vendor.update(total_inventory: vendor.variants.pluck(:permanent_stock).sum)
      end
    end
  end
end
