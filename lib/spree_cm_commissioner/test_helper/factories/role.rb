FactoryBot.define do
  factory :cm_role, class: 'Spree::Role' do
    sequence(:name) { |n| "Role_#{n}" }
    presentation { 'test' }
    vendor_id { nil }
  end
end