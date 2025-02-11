FactoryBot.define do
  factory :cm_address, class: Spree::Address do
    firstname { 'John' }
    lastname { 'Doe' }
    address1 { '123 Main St' }
    address2 { 'Apt 4B' }
    city { 'Los Angeles' }
    zipcode { '90001' }
    phone { '1234567890' }
    company { 'TechCorp' }
    label { 'Home' }
    public_metadata { { key: 'value' } }
    age { 30 }
    gender { 1 }

    association :state, factory: :cm_state
    association :country, factory: :cm_country
  end
end
