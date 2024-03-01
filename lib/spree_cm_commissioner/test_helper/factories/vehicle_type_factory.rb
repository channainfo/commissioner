FactoryBot.define do
  factory :vehicle_type, class: SpreeCmCommissioner::VehicleType do
    name { FFaker::Name.name }
    route_type {"automobile"}
    status {"active"}
  end

  trait :with_layers do
    transient do
      layers {[
        {row: 1, column: 1, empty: [[]], label: 'F', layer_name: "First Layer"},
        {row: 1, column: 1, empty: [[]], label: 'S', layer_name: "Second Layer"}
      ]}
    end
    after(:create) do |vehicle_type, evaluator|
      layers = evaluator.layers || [{}]
      layers.each_with_index do |layer, index|

        row = layer[:row]
        column = layer[:column]
        empty_seats = layer[:empty] || []
        label_counter = 1
        layer_name = layer[:layer_name]
        row.times do |r|
          column.times do |c|
            label = "#{layer[:label]}#{label_counter}"
            seat_type = 0
            if empty_seats.include?([r, c])
              seat_type = 1
              label = "NA"
              label_counter -= 1
            end
            if (r == 0 && c == 0 && index == 0)
              seat_type = 3
              label = "NA"
              label_counter -= 1
            end
            seat = {
              "row": r + 1,
              "column": c + 1,
              "label": label,
              "layer": layer_name,
              "seat_type": seat_type,
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

  trait :with_seats do
    transient do
      row { 1 }
      column { 1 }
      empty { [[]] }
    end

    after(:create) do |vehicle_type, evaluator|
      label_counter = 1
      empty_seats = evaluator.empty || []
      evaluator.row.times do |r|
        evaluator.column.times do |c|
          seat_type = 0
          label = "F#{label_counter}"
          if empty_seats.include?([r, c])
            seat_type = 1
            label = "NA"
            label_counter -= 1
          end
          if (r == 0 && c == 0)
            seat_type = 3
            label = "NA"
            label_counter -= 1
          end
          seat = {
            "row": r + 1,
            "column": c + 1,
            "label": label,
            "layer": "First Layer",
            "seat_type": seat_type,
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
