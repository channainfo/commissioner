FactoryBot.define do
  factory :oauth_access_token, class: Spree::OauthAccessToken do
    sequence(:token) { |n| "token-#{n}" }
  end
end
