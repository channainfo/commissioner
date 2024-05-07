FactoryBot.define do

  factory :cm_stop_time , class: SpreeCmCommissioner::StopTime do
    trip_id
    to_stop_id
    from_stop_id
    sequence
    vehicle_id
    time
  end
end
