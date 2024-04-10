FactoryBot.define do
  factory :cm_pricing_rule, class: SpreeCmCommissioner::PricingRule do
    pricing_ruleable { |r| r.association(:cm_pricing_rate) }
  end
end
