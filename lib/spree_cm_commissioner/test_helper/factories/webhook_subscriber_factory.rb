FactoryBot.define do
  factory :cm_webhook_subscriber, class: Spree::Webhooks::Subscriber do
    sequence(:name) { |n| "subscriber-#{n}" }
    sequence(:url) { |n| "https://www.url#{n}.com/" }

    api_key { SecureRandom::hex(32) }
    match_policy { 'all' }
    preferences { nil }
    subscriptions { [] }
    active { true }

    trait :active do
      active { true }
    end

    trait :inactive do
      active { false }
    end
  end
end
