FactoryBot.define do
  factory :cm_pricing_model, class: SpreeCmCommissioner::PricingModel do
    match_policy { :all }
    effective_from { nil }
    effective_to { nil }
    pricing_modelable { |r| r.association(:variant) }

    transient do
      percent_adjustment { nil }
      flat_adjustment { nil }
    end

    after(:build) do |rule, evaluator|
      if evaluator.flat_adjustment.present?
        rule.pricing_actions << build(:cm_calculate_adjustment_pricing_action, flat_adjustment: evaluator.flat_adjustment)
      end

      if evaluator.percent_adjustment.present?
        rule.pricing_actions << build(:cm_calculate_adjustment_pricing_action, percent_adjustment: evaluator.percent_adjustment)
      end
    end
  end
end
