FactoryBot.define do
  factory :vehicle, class: SpreeCmCommissioner::Vehicle do
    sequence(:code) { |n| "vehicle_#{n}" }
    sequence(:license_plate) { |n| "2KH-#{'%04d' % (n % 10000)}" }
  end
end
