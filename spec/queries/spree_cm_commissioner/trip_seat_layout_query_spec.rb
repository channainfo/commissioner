require 'spec_helper'

RSpec.describe SpreeCmCommissioner::TripSeatLayoutQuery do
  #vendor
  let!(:vet) {create(:vendor, name: 'Vet', code:"VET")}

  #location
  let!(:phnom_penh) { create(:transit_place, name: 'Phnom Penh', data_type:4) }
  let!(:siem_reap) { create(:transit_place, name: 'Siem Reap', data_type:4) }

  #Vehicle Type
  let!(:airbus) {create(:vehicle_type,
                        :with_seats,
                        code: "AIRBUS",
                        vendor: vet,
                        row: 10,
                        column: 5,
                        empty: [[0,2],[1,2],[2,2],[3,2],[4,2],[5,0],[5,1],[5,2],[6,0],[6,1],[6,2],[7,2],[8,2]]
                        )}

  let!(:minivan) {create(:vehicle_type,
                        :with_seats,
                        code: "minivan",
                        vendor: vet,
                        row: 5,
                        column: 4,
                        empty: [[0,1],[1,2],[1,3],[2,2],[3,2]]
                        )}

  let!(:sleeping_bus) {create(:vehicle_type,
                                  :with_layers,
                                  code: "sleeping_bus",
                                  vendor: vet,
                                  layers: [
                                    { row: 6,
                                      column: 4,
                                      label:"F",
                                      layer_name:"First Layer",
                                      empty: [[0,1],[0,2],[0,3],[1,2],[1,3],[2,2],[3,2],[4,2],[5,2],[5,3]]
                                    },
                                    { row: 6,
                                      column: 4,
                                      label:"S",
                                      layer_name:"Second Layer",
                                      empty: [[0,2],[0,3],[1,2],[2,2],[3,2],[4,2],[5,2]]
                                    }]
                                  )}

  let!(:bus1) {create(:vehicle, vehicle_type: airbus, vendor: vet)}
  let!(:minivan1) {create(:vehicle, vehicle_type: minivan, vendor: vet)}
  let!(:sleeping_bus1) {create(:vehicle, vehicle_type: sleeping_bus, vendor: vet)}

  #option_type
  let!(:duration) {create(:option_type, name: 'duration', presentation: 'Duration', attr_type: 'duration', kind: 'variant')}
  let!(:departure_time) {create(:option_type, name: 'departure_time', presentation: 'Departure Time', attr_type: 'departure_time', kind: 'variant')}
#option_value
  let!(:dt_13) {create(:option_value, name: '13:00', presentation: '13:00', option_type: departure_time)}
  let!(:dt_10) {create(:option_value, name: '10:00', presentation: '10:00', option_type: departure_time)}
  let(:duration_3) {create(:option_value, name: '3', presentation: '3', option_type: duration)}
  let(:duration_6) {create(:option_value, name: '6', presentation: '6', option_type: duration)}


  #routes
  let!(:phnom_penh_to_siem_reap_by_airbus) { create(:route,
                                                :with_option_types,
                                                name: 'Phnom Penh to Siem Reap by Vet Airbus',
                                                short_name:"PP-SR",
                                                vendor: vet,
                                                origin_id: phnom_penh.id,
                                                destination_id: siem_reap.id,
                                                departure_time: departure_time,
                                                duration: duration,
                                                vehicle_id: bus1.id) }

  let!(:phnom_penh_to_siem_reap_by_minivan) { create(:route,
                                                    :with_option_types,
                                                    name: 'Phnom Penh to Siem Reap by Larryta',
                                                    short_name:"PP-SR",
                                                    vendor: vet,
                                                    origin_id: phnom_penh.id,
                                                    destination_id: siem_reap.id,
                                                    departure_time: departure_time,
                                                    duration: duration,
                                                    vehicle_id: minivan1.id) }

  let!(:phnom_penh_to_siem_reap_by_sleeping_bus) { create(:route,
                                                              :with_option_types,
                                                              name: 'Phnom Penh to Siem Reap by Vet Sleeping Bus',
                                                              short_name:"PP-SR",
                                                              vendor: vet,
                                                              origin_id: phnom_penh.id,
                                                              destination_id: siem_reap.id,
                                                              departure_time: departure_time,
                                                              duration: duration,
                                                              vehicle_id: sleeping_bus1.id) }
  let!(:sleeping_bus_pp_to_sr_trip) {create(:trip,
                                route: phnom_penh_to_siem_reap_by_sleeping_bus,
                                sku: 'SLEEP-BUS-PP-SR-10:00-6',
                                departure_time: dt_10,
                                duration: duration_6
                                )}

  let!(:airbus_pp_to_sr_trip) {create(:trip,
                                  route: phnom_penh_to_siem_reap_by_airbus,
                                  sku: 'VET-PP-SR-10:00-6',
                                  departure_time: dt_10,
                                  duration: duration_6
                                  )}

  let!(:minivan_pp_to_sr_trip) {create(:trip,
                                        route: phnom_penh_to_siem_reap_by_minivan,
                                        sku: 'LTA-PP-SR-13:00-6',
                                        departure_time: dt_13,
                                        duration: duration_3,
                                        )}
#date
let!(:today) {Date.today}
let!(:tomorrow) {today + 1.day}

#airbus_seats
  let!(:arb_f1_seat) {airbus.vehicle_seats.find_by(label: "F1")}
  let!(:arb_f2_seat) {airbus.vehicle_seats.find_by(label: "F2")}
  let!(:arb_f3_seat) {airbus.vehicle_seats.find_by(label: "F3")}
  let!(:arb_f4_seat) {airbus.vehicle_seats.find_by(label: "F4")}
  let!(:arb_f5_seat) {airbus.vehicle_seats.find_by(label: "F5")}
  let!(:arb_f6_seat) {airbus.vehicle_seats.find_by(label: "F6")}
  let!(:arb_f7_seat) {airbus.vehicle_seats.find_by(label: "F7")}
  let!(:arb_f8_seat) {airbus.vehicle_seats.find_by(label: "F8")}
  let!(:arb_f9_seat) {airbus.vehicle_seats.find_by(label: "F9")}

  #minivan_seats
  let!(:slb_f1_seat) {sleeping_bus.vehicle_seats.find_by(label: "F1")}
  let!(:slb_f2_seat) {sleeping_bus.vehicle_seats.find_by(label: "F2")}
  let!(:slb_f3_seat) {sleeping_bus.vehicle_seats.find_by(label: "F3")}
  let!(:slb_f4_seat) {sleeping_bus.vehicle_seats.find_by(label: "F4")}
  let!(:slb_f5_seat) {sleeping_bus.vehicle_seats.find_by(label: "F5")}
  let!(:slb_s6_seat) {sleeping_bus.vehicle_seats.find_by(label: "S6")}
  let!(:slb_s7_seat) {sleeping_bus.vehicle_seats.find_by(label: "S7")}
  let!(:slb_s16_seat) {sleeping_bus.vehicle_seats.find_by(label: "S16")}
  let!(:slb_s17_seat) {sleeping_bus.vehicle_seats.find_by(label: "S17")}

  #minivan_seats
  let!(:mvn_f1_seat) {minivan.vehicle_seats.find_by(label: "F1")}
  let!(:mvn_f2_seat) {minivan.vehicle_seats.find_by(label: "F2")}
  let!(:mvn_f3_seat) {minivan.vehicle_seats.find_by(label: "F3")}
  let!(:mvn_f4_seat) {minivan.vehicle_seats.find_by(label: "F4")}
  let!(:mvn_f5_seat) {minivan.vehicle_seats.find_by(label: "F5")}
  let!(:mvn_f6_seat) {minivan.vehicle_seats.find_by(label: "F6")}
  let!(:mvn_f7_seat) {minivan.vehicle_seats.find_by(label: "F7")}
  let!(:mvn_f8_seat) {minivan.vehicle_seats.find_by(label: "F8")}
  let!(:mvn_f9_seat) {minivan.vehicle_seats.find_by(label: "F9")}

  #order
  let!(:order1) {create(:transit_order, variant: airbus_pp_to_sr_trip, seats: [arb_f1_seat,arb_f4_seat], date: today)}
  let!(:order2) {create(:transit_order, variant: airbus_pp_to_sr_trip, seats: [arb_f5_seat,arb_f6_seat,arb_f7_seat,arb_f8_seat,arb_f9_seat], date: today)}
  let!(:order3) {create(:transit_order, variant: minivan_pp_to_sr_trip, seats: [mvn_f1_seat,mvn_f2_seat], date: today)}
  let!(:order4) {create(:transit_order, variant: minivan_pp_to_sr_trip, seats: [mvn_f5_seat,mvn_f6_seat], date: today)}
  let!(:order5) {create(:transit_order, variant: sleeping_bus_pp_to_sr_trip, seats: [slb_f1_seat,slb_f2_seat], date: today)}
  let!(:order6) {create(:transit_order, variant: sleeping_bus_pp_to_sr_trip, seats: [slb_s16_seat,slb_s17_seat], date: today)}




  describe"#call" do
    context "display seats layout table for Sleeping Bus" do
      let(:records) {described_class.new(trip_id: sleeping_bus_pp_to_sr_trip.id, date: today)}
      it "return Sleeping Bus seats layout" do
        result = records.call
        result.each do |layer, rows|
          rows_table = Terminal::Table.new do |t|
            rows.each do |row_num, seats|
              row = seats.map do |seat|
                if seat[:seat_type] == "normal"
                  seat[:seat_id] == nil ? "#{seat[:label]}  " : "#{seat[:label]} x "
                else
                 seat[:seat_type] == "driver" ? "D   " : "   "
                end
              end
              t.add_row row
            end
          end

          puts "#{layer}\n#{rows_table}"
        end
      end
    end

    context "display seats layout table for Airbus Bus" do
      let(:records) {described_class.new(trip_id: airbus_pp_to_sr_trip.id, date: today)}
      it "return Air Bus seats layout" do
        result = records.call
        result.each do |layer, rows|
          rows_table = Terminal::Table.new do |t|
            rows.each do |row_num, seats|
              row = seats.map do |seat|
                if seat[:seat_type] == "normal"
                  seat[:seat_id] == nil ? "#{seat[:label]}  " : "#{seat[:label]} x "
                else
                 seat[:seat_type] == "driver" ? "D   " : "   "
                end
              end
              t.add_row row
            end
          end

          puts "#{layer}\n#{rows_table}"
        end
      end
    end

    context "display seats layout table for Minivan" do
      let(:records) {described_class.new(trip_id: minivan_pp_to_sr_trip.id, date: today)}
      it "return Minivan seats layout" do
        result = records.call
        result.each do |layer, rows|
          rows_table = Terminal::Table.new do |t|
            rows.each do |row_num, seats|
              row = seats.map do |seat|
                if seat[:seat_type] == "normal"
                  seat[:seat_id] == nil ? "#{seat[:label]}  " : "#{seat[:label]} x "
                else
                 seat[:seat_type] == "driver" ? "D   " : "   "
                end
              end
              t.add_row row
            end
          end

          puts "#{layer}\n#{rows_table}"
        end
      end
    end
  end
end
