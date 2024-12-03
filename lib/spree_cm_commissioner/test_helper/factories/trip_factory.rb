# FactoryBot.define do
#   factory :trip, class: SpreeCmCommissioner::Trip do
#     product { create(:route) }
#     permanent_stock { 5 }
#     vendor {create(:vendor, name: 'Vet Airbus', code:"VET")}
#     phnom_penh { create(:transit_place, name: 'Phnom Penh', data_type:4) }
#     siem_reap { create(:transit_place, name: 'Siem Reap', data_type:4) }
#     airbus {create(:vehicle_type,
#                         :with_seats,
#                         code: "AIRBUS",
#                         vendor: vet_airbus,
#                         row: 4,
#                         column: 4)}

#     bus1 {create(:vehicle, vehicle_type: airbus, vendor: vet_airbus)}
#     route { create(:route,
#                                                 trip_attributes: {
#                                                   origin_id: phnom_penh.id,
#                                                   destination_id: siem_reap.id,
#                                                   departure_time: '10:00',
#                                                   duration: 6,
#                                                   vehicle_id: bus1.id
#                                                 },
#                                                 name: 'VET Airbus Phnom Penh Siem Reap 10:00',
#                                                 short_name:"PP-SR-10:00-6",
#                                                 vendor: vet_airbus
#                                                 ) }
#     transient do
#       departure_time { "10:00" }
#       duration { "1" }
#     end
#     before(:create) do |trip, evaluator|
#       trip.option_values = [evaluator.departure_time, evaluator.duration]
#     end
#     after(:create) do |trip, evaluator|
#       trip.stock_items = [create(:stock_item, variant: trip, stock_location: evaluator.product.vendor.stock_locations.first)]
#       trip.stock_items.first.adjust_count_on_hand(10)
#     end
#   end
# end
