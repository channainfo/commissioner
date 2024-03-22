FactoryBot.define do
  factory :cm_pricing_model, class: SpreeCmCommissioner::PricingModel do
    match_policy { :all }
    effective_from { nil }
    effective_to { nil }

    transient do
      percent_adjustment { nil }
      flat_adjustment { nil }
    end

    after(:build) do |rule, evaluator|
      if evaluator.flat_adjustment.present?
        rule.pricing_actions << SpreeCmCommissioner::PricingActions::CalculateAdjustment.new(
          calculator: Spree::Calculator::FlatRate.new(
            preferred_amount: evaluator.flat_adjustment,
            preferred_currency: Spree::Store.default.default_currency
          )
        )
      end

      if evaluator.percent_adjustment.present?
        rule.pricing_actions << SpreeCmCommissioner::PricingActions::CalculateAdjustment.new(
          calculator: Spree::Calculator::PercentOnLineItem.new(preferred_percent: evaluator.percent_adjustment)
        )
      end
    end
  end
end
