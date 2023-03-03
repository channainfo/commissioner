FactoryBot.define do
  factory :cm_vendor_pricing_rule, class: SpreeCmCommissioner::VendorPricingRule do
    vendor    { vendor }
    date_rule { { type: 'fixed_date', name: 'Special Day', value: '01/03/2023' } }
    operator  { '+' }
    amount     { FFaker::Number.decimal }
    length    { FFaker::Number.number }
    position          { FFaker::Number.number }
    active            { true }
    free_cancellation { false }
  end
end