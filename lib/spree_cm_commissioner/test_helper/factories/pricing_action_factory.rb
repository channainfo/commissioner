FactoryBot.define do
  factory :cm_pricing_action, class: SpreeCmCommissioner::PricingAction do
  end

  factory :cm_calculate_adjustment_pricing_action, class: SpreeCmCommissioner::PricingActions::CalculateAdjustment do
    transient do
      percent_adjustment { nil }
      flat_adjustment { nil }
    end

    after(:build) do |action, evaluator|
      if evaluator.flat_adjustment.present?
        action.calculator = Spree::Calculator::FlatRate.new(preferred_amount: evaluator.flat_adjustment, preferred_currency: Spree::Store.default.default_currency)
      elsif evaluator.percent_adjustment.present?
        action.calculator = Spree::Calculator::PercentOnLineItem.new(preferred_percent: evaluator.percent_adjustment)
      end
    end
  end
end
