FactoryBot.define do
  factory :cm_stock_location, class: Spree::StockLocation do
    name { FFaker::Name.unique.name }
    address1 { '1600 Pennsylvania Ave NW' }
    city { 'Phnom Penh' }
    zipcode { '20500' }
    phone { '+855 56 123 789' }
    active { true }
    backorderable_default { true }
    lat { 10.627543 }
    lon { 103.522141 }

    country { Spree::Country.first || create(:cm_country) }
    state do |stock_location|
      stock_location.country.states.first || create(:cm_state, country: stock_location.country)
    end
  end
end
