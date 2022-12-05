FactoryBot.define do
  factory :user_identity_provider, class: SpreeCmCommissioner::UserIdentityProvider do
    sequence(:sub) { |n| "sub-#{n}" }
    identity_type { SpreeCmCommissioner::UserIdentityProvider.identity_types[:google] }
    email { 'fake@example.com' }
  end
end
