FactoryBot.define do
  factory :cm_state, class: Spree::State do
    name { 'California' }
    abbr { 'CA' }
    association :country, factory: :cm_country
  end
end
