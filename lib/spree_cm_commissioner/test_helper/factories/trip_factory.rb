FactoryBot.define do
  factory :trip_connection, class: 'SpreeCmCommissioner::TripConnection' do
    association :from_trip, factory: :variant
    association :to_trip, factory: :variant
  end
end
