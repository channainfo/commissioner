FactoryBot.define do
  factory :cm_pricing_model_action, class: SpreeCmCommissioner::PricingModel::Actions::CreateListingPriceAdjustment do
    pricing_model { create(:cm_pricing_model) }
    calculator { Spree::Calculator::FlatRate.new(preferred_amount: 10.0) }
  end
end
