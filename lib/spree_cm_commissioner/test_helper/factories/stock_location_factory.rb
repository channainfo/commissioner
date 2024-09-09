FactoryBot.define do
  factory :cm_stock_location, class: Spree::StockLocation do
    name                  { FFaker::Name.unique.name }
    address1              { '1600 Pennsylvania Ave NW' }
    city                  { 'Washington' }
    zipcode               { '20500' }
    phone                 { '(202) 456-1111' }
    active                { true }
    backorderable_default { true }
    lat                   { 00.to_d }
    lon                   { 000.to_d }

    transient {
      state_name { 'Phnom Penh' }
     }

    country  { |stock_location| Spree::Country.first || stock_location.association(:country) }
    state do |stock_location|
      stock_location.country.states.find_by(name: state_name) || stock_location.association(:state, name: state_name, country: stock_location.country)
    end

    factory :cm_stock_location_with_items do
      after(:create) do |stock_location, _evaluator|
        # variant will add itself to all stock_locations in an after_create
        # creating a product will automatically create a master variant
        store = Spree::Store.first || create(:store)
        product_1 = create(:product, stores: [store])
        product_2 = create(:product, stores: [store])

        stock_location.stock_items.where(variant_id: product_1.master.id).first.adjust_count_on_hand(10)
        stock_location.stock_items.where(variant_id: product_2.master.id).first.adjust_count_on_hand(20)
      end
    end
  end
end