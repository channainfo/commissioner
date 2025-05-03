FactoryBot.define do
  factory :cm_place, class: SpreeCmCommissioner::Place do
    name                  { FFaker::Name.unique.name }
    reference             { FFaker::Guid.guid }
    vicinity              { FFaker::Address.street_address }
    icon                  { FFaker::Avatar.image }
    url                   { FFaker::Internet.http_url }
    rating                { FFaker::Number.decimal }
    formatted_address     { FFaker::Address.street_address }
    address_components    { FFaker::Address.street_address }
    lat                   { FFaker::Geolocation.lat }
    lon                   { FFaker::Geolocation.lng }
    trait :with_parent do
      association :parent, factory: :cm_place
    end
    transient do
      children_count { 0 }
    end

    after(:create) do |place, evaluator|
      create_list(:cm_place, evaluator.children_count, parent: place)
    end
  end
end
