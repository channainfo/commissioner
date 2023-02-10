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
  end
end