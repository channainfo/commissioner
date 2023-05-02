FactoryBot.define do
  factory :cm_device_token, class: SpreeCmCommissioner::DeviceToken do
    user factory: :cm_user
    sequence(:registration_token) { |n| "device-token=#{n}" }
    client_name {'cm-market'}
    client_version {'1.0.0'}
    meta {'first-notification'}
  end
end