FactoryBot.define do
  factory :cm_vendor_place, class: SpreeCmCommissioner::VendorPlace do
    vendor    { vendor}
    place     { place }
    distance  { FFaker::Number.decimal }
    position  { FFaker::Number.number }
  end
end