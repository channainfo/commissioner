FactoryBot.define do
  factory :vehicle_type, class: SpreeCmCommissioner::VehicleType do
    name { FFaker::Name.name }
    route_type {"automobile"}
    status {"active"}
  end
  trait :with_seats do
    transient do
      row { 1 }
      column { 1 }
    end

    after(:create) do |vehicle_type, evaluator|
      label_counter = 1
      evaluator.row.times do |r|
        evaluator.column.times do |c|
          seat = {
            "row": r + 1,
            "column": c + 1,
            "label": "F#{label_counter}",
            "layer": "First Layer",
            "seat_type": 0,
            "vehicle_type_id": vehicle_type.id
          }

          label_counter += 1
          SpreeCmCommissioner::VehicleSeat.create(seat)
        end
      end
      vehicle_type.reload
    end
  end
end
