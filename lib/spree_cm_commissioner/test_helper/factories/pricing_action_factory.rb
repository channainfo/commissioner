FactoryBot.define do
  factory :cm_pricing_action, class: SpreeCmCommissioner::PricingAction do
    pricing_model { |a| a.association(:cm_pricing_model) }
  end
end
