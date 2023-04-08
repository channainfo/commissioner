FactoryBot.define do
  sequence(:phone_number) { FFaker::PhoneNumber.phone_number }

  factory :cm_customer , class: SpreeCmCommissioner::Customer do
    first_name { 'John'}
    last_name { 'Wick' }
    email { generate(:random_email) }
    phone_number { generate(:phone_number) }
    user { create(:user) }

    vendor
  end
end