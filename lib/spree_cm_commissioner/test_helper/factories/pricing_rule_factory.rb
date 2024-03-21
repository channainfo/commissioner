FactoryBot.define do
  factory :cm_pricing_rule, class: SpreeCmCommissioner::PricingRule do; end

  factory :cm_quantity_pricing_rule, class: SpreeCmCommissioner::PricingRules::Quantity do
    preferred_min_quantity { 3 }
    preferred_max_quantity { 3 }

    transient do
      quantity { nil }
      min_quantity { nil }
      max_quantity { nil }
    end

    after(:build) do |rule, evaluator|
      if evaluator.quantity.present?
        rule.preferred_min_quantity = evaluator.quantity
        rule.preferred_max_quantity = evaluator.quantity
      elsif evaluator.min_quantity.present? && evaluator.max_quantity.present?
        rule.preferred_min_quantity = evaluator.min_quantity
        rule.preferred_max_quantity = evaluator.max_quantity
      end
    end
  end

  factory :cm_custom_date_pricing_rule, class: SpreeCmCommissioner::PricingRules::CustomDates do
    preferred_custom_dates { [] }

    transient do
      year { Date.current.year }
      women_right { false }
    end

    after(:build) do |rule, evaluator|
      if evaluator.women_right == true
        rule.preferred_custom_dates << { start_date: "#{evaluator.year}-03-08", length: "1", title: "Women Right" }.to_json
      end
    end
  end

  factory :cm_extra_adults_pricing_rule, class: SpreeCmCommissioner::PricingRules::ExtraAdults do
    preferred_min_extra_adults { 2 }
    preferred_max_extra_adults { 2 }

    transient do
      extra_adults { nil }
      min_extra_adults { nil }
      max_extra_adults { nil }
    end

    after(:build) do |rule, evaluator|
      if evaluator.extra_adults.present?
        rule.preferred_min_extra_adults = evaluator.extra_adults
        rule.preferred_max_extra_adults = evaluator.extra_adults
      elsif evaluator.min_extra_adults.present? && evaluator.max_extra_adults.present?
        rule.preferred_min_extra_adults = evaluator.min_extra_adults
        rule.preferred_max_extra_adults = evaluator.max_extra_adults
      end
    end
  end

  factory :cm_extra_kids_pricing_rule, class: SpreeCmCommissioner::PricingRules::ExtraKids do
    preferred_min_extra_kids { 2 }
    preferred_max_extra_kids { 2 }

    transient do
      extra_kids { nil }
      min_extra_kids { nil }
      max_extra_kids { nil }
    end

    after(:build) do |rule, evaluator|
      if evaluator.extra_kids.present?
        rule.preferred_min_extra_kids = evaluator.extra_kids
        rule.preferred_max_extra_kids = evaluator.extra_kids
      elsif evaluator.min_extra_kids.present? && evaluator.max_extra_kids.present?
        rule.preferred_min_extra_kids = evaluator.min_extra_kids
        rule.preferred_max_extra_kids = evaluator.max_extra_kids
      end
    end
  end

  factory :cm_early_bird_pricing_rule, class: SpreeCmCommissioner::PricingRules::EarlyBird do
    preferred_booking_date_from { Date.current.to_s }
    preferred_booking_date_to { (Date.current + 3.days).to_s }

    transient do
      from { nil }
      to { nil }
    end

    after(:build) do |rule, evaluator|
      if evaluator.from.present?
        rule.preferred_booking_date_from = evaluator.from.to_s
      elsif evaluator.to.present?
        rule.preferred_booking_date_to = evaluator.to.to_s
      end
    end
  end
end
