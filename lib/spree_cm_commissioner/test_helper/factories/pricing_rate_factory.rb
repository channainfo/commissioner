FactoryBot.define do
  factory :cm_pricing_rate, class: SpreeCmCommissioner::PricingRate do
    match_policy { :all }
    effective_from { nil }
    effective_to { nil }

    pricing_rateable { |r| r.association(:variant) }
  end
end
