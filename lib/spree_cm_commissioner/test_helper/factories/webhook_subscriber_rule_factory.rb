FactoryBot.define do
  factory :cm_webhook_subscriber_rule, class: SpreeCmCommissioner::Webhooks::SubscriberRule do
    subscriber { create(:cm_webhook_subscriber) }

    factory :cm_webhook_subscriber_order_vendors_rule, class: SpreeCmCommissioner::Webhooks::Rules::OrderVendors do
      transient do
        vendors { [create(:vendor)]}
        match_policy { 'all' }
      end

      after(:build) do |rule, evaluator|
        rule.preferred_vendors = evaluator.vendors.pluck(:id).map(&:to_s)
        rule.preferred_match_policy = evaluator.match_policy
      end
    end

    factory :cm_webhook_subscriber_order_states_rule, class: SpreeCmCommissioner::Webhooks::Rules::OrderStates do
      transient do
        states { SpreeCmCommissioner::Webhooks::Rules::OrderStates::DEFAULT_STATES }
      end

      after(:build) do |rule, evaluator|
        rule.preferred_states = evaluator.states
      end
    end
  end
end
