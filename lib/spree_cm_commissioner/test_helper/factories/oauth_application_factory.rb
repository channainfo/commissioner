FactoryBot.define do
  factory :oauth_application, class: Spree::OauthApplication do
    sequence(:name) { |n| "Name-#{n}" }

    confidential { true }
    redirect_uri { 'urn:ietf:wg:oauth:2.0:oob' }
  end
end
