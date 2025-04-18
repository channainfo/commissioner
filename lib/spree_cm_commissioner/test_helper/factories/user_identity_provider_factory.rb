FactoryBot.define do
  factory :user_identity_provider, class: SpreeCmCommissioner::UserIdentityProvider do
    sequence(:sub) { |n| "sub-#{n}" }
    identity_type { SpreeCmCommissioner::UserIdentityProvider.identity_types[:google] }
    email { 'fake@example.com' }
    user { |t| t.association(:user) }

    trait :telegram do
      identity_type { SpreeCmCommissioner::UserIdentityProvider.identity_types[:telegram] }
    end

    trait :vattanac_bank do
      identity_type { SpreeCmCommissioner::UserIdentityProvider.identity_types[:vattanac_bank] }
    end
  end
end
