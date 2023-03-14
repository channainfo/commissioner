FactoryBot.define do
  factory :cm_pricing_model_rule, class: SpreeCmCommissioner::PricingModel::Rules::FixedDate do
    preferred_match_policy { 'any' }
    preferred_start_date { '2023-02-21' }
    preferred_length { 2 }
    vendor { create(:vendor) }
  end
end
