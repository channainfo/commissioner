FactoryBot.define do
  factory :notification, class: SpreeCmCommissioner::Notification do
    notificable(factory: :order)
    recipient(factory: :cm_user)
    params { '' }

    trait :unread do
      read_at  { nil }
    end

    trait :read do
      read_at { Time.current }
    end
  end
end
