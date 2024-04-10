FactoryBot.define do
  factory :cm_pricing_rule, class: SpreeCmCommissioner::PricingRule do
    ruleable { |r| r.association(:cm_pricing_rate) }

    factory :cm_custom_date_pricing_rule, class: SpreeCmCommissioner::PricingRules::CustomDates do
      preferred_custom_dates { [] }

      transient do
        dates { nil }
      end

      after(:build) do |rule, evaluator|
        if evaluator.dates.present?
          rule.preferred_custom_dates += evaluator.dates.map { |date| { start_date: date, length: "1", title: date }.to_json }
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
        end

        if evaluator.to.present?
          rule.preferred_booking_date_to = evaluator.to.to_s
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

    factory :cm_group_pricing_rule, class: SpreeCmCommissioner::PricingRules::GroupBooking do
      preferred_quantity { 3 }

      transient do
        quantity { nil }
      end

      after(:build) do |rule, evaluator|
        if evaluator.quantity.present?
          rule.preferred_quantity = evaluator.quantity
        end
      end
    end

    factory :cm_weekdays_pricing_rule, class: SpreeCmCommissioner::PricingRules::Weekend do
      preferred_weekend_days { [6, 0] }

      transient do
        weekend_days { nil }
      end

      after(:build) do |rule, evaluator|
        if evaluator.weekend_days.present?
          rule.preferred_weekend_days = evaluator.weekend_days.map(&:to_s)
        end
      end
    end
  end
end
