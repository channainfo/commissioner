FactoryBot.define do
  factory :cm_pricing_model, class: SpreeCmCommissioner::PricingModel do
    match_policy { :all }
    effective_from { nil }
    effective_to { nil }
    modelable { |r| r.association(:variant) }
  end
end
