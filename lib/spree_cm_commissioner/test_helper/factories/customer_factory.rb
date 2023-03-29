FactoryBot.define do
  factory :cm_customer , class: SpreeCmCommissioner::Customer do
    first_name { 'John'}
    last_name { 'Wick' }
    email { 'johnwick@gmail.com' }
    phone_number { '0962200288' }
    user { create(:user) }
    vendor
  end
end