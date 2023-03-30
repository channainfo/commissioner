FactoryBot.define do
  factory :cm_customer, class: SpreeCmCommissioner::Customer do
    vendor

    phone_number { '0962200288' }
    user { create(:user) }
  end
end