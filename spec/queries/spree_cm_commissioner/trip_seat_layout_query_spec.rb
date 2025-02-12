require 'spec_helper'

RSpec.describe SpreeCmCommissioner::TripSeatLayoutQuery do
  #vendor
  let!(:vet) {create(:vendor, name: 'Vet', code:"VET")}
  let!(:buva_sea) {create(:vendor, name:'Buva Sea', code:"BS")}
  #location
  let!(:phnom_penh) { create(:transit_place, name: 'Phnom Penh', data_type:4) }
  let!(:siem_reap) { create(:transit_place, name: 'Siem Reap', data_type:4) }
  let!(:sihanoukville) { create(:transit_place, name: 'Sihanoukville', data_type:4) }
  let!(:koh_rong) {create(:transit_place, name: 'Koh Rong', data_type:4)}

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
  let!(:ferry) {create(:vehicle_type,
                :with_seats,
                code: 'ferry',
                vendor: buva_sea,
                vehicle_seats_count: 100,
                )}

  let!(:bus1) {create(:vehicle, vehicle_type: airbus, vendor: vet)}
  let!(:minivan1) {create(:vehicle, vehicle_type: minivan, vendor: vet)}
  let!(:sleeping_bus1) {create(:vehicle, vehicle_type: sleeping_bus, vendor: vet)}
  let!(:ferry1) {create(:vehicle, vehicle_type: ferry, vendor: buva_sea)}

  #routes
  let!(:phnom_penh_to_siem_reap_by_airbus) { create(:route,
                                                trip_attributes: {
                                                  origin_id: phnom_penh.id,
                                                  destination_id: siem_reap.id,
                                                  departure_time: '10:00',
                                                  duration: 6,
                                                  vehicle_id: bus1.id
                                                },
                                                name: 'Phnom Penh to Siem Reap by Vet Airbus',
                                                short_name:"PP-SR",
                                                vendor: vet) }

  let!(:phnom_penh_to_siem_reap_by_minivan) { create(:route,
                                                    trip_attributes: {
                                                      origin_id: phnom_penh.id,
                                                      destination_id: siem_reap.id,
                                                      departure_time: '13:00',
                                                      duration: 6,
                                                      vehicle_id: minivan1.id
                                                    },
                                                    name: 'Phnom Penh to Siem Reap by Larryta',
                                                    short_name:"PP-SR",
                                                    vendor: vet) }

  let!(:phnom_penh_to_siem_reap_by_sleeping_bus) { create(:route,
                                                              trip_attributes: {
                                                                origin_id: phnom_penh.id,
                                                                destination_id: siem_reap.id,
                                                                departure_time: '10:00',
                                                                duration: 6,
                                                                vehicle_id: sleeping_bus1.id
                                                              },
                                                              name: 'Phnom Penh to Siem Reap by Vet Sleeping Bus',
                                                              short_name:"PP-SR",
                                                              vendor: vet) }
  let!(:sihanoukville_to_koh_rong_by_ferry) {create(:route,
                                                        trip_attributes: {
                                                          origin_id: sihanoukville.id,
                                                          destination_id: koh_rong.id,
                                                          departure_time: '10:00',
                                                          duration: 6,
                                                          vehicle_id: ferry1.id,
                                                          allow_seat_selection: false
                                                        },
                                                        name: "Sihanoukville to Koh Rong by Buva Sea Ferry",
                                                        short_name: "SV-KR",
                                                        vendor: buva_sea)}
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
  let!(:order1) {create(:transit_order, variant: phnom_penh_to_siem_reap_by_airbus.master, seats: [arb_f1_seat,arb_f4_seat], date: today)}
  let!(:order2) {create(:transit_order, variant: phnom_penh_to_siem_reap_by_airbus.master, seats: [arb_f5_seat,arb_f6_seat,arb_f7_seat,arb_f8_seat,arb_f9_seat])}
  let!(:order3) {create(:transit_order, variant: phnom_penh_to_siem_reap_by_minivan.master, seats: [mvn_f1_seat,mvn_f2_seat], date: today)}
  let!(:order4) {create(:transit_order, variant: phnom_penh_to_siem_reap_by_minivan.master, seats: [mvn_f5_seat,mvn_f6_seat], date: today)}
  let!(:order5) {create(:transit_order, variant: phnom_penh_to_siem_reap_by_sleeping_bus.master, seats: [slb_f1_seat,slb_f2_seat], date: today)}
  let!(:order6) {create(:transit_order, variant: phnom_penh_to_siem_reap_by_sleeping_bus.master, seats: [slb_s16_seat,slb_s17_seat], date: today)}
  let!(:order7) {create(:transit_order, variant: sihanoukville_to_koh_rong_by_ferry.master, date: tomorrow, quantity: 3, state: 'payment', payment_state: nil)}
  let!(:order8) {create(:transit_order, variant: sihanoukville_to_koh_rong_by_ferry.master, date: tomorrow, quantity: 5)}





  describe"#call" do
    context "display seats layout table for Sleeping Bus" do
      let(:records) {described_class.new(trip_id: phnom_penh_to_siem_reap_by_sleeping_bus.master.id, date: today)}
      it "return Sleeping Bus seats layout" do
        result = records.call
        layout = result.layout
        puts "Total Seats: #{result.total_seats}"
        puts "Sold: #{result.total_sold}"
        puts "Remaining: #{result.remaining_seats}"
        layout.each do |layer, rows|
          rows_table = Terminal::Table.new do |t|
            rows.each do |row_num, seats|
              row = seats.map do |seat|
                if seat[:seat_type] == "normal"
                  seat[:seat_id] == nil ? " #{seat[:label]}" : "x#{seat[:label]}"
                else
                 seat[:seat_type] == "driver" ? "D   " : " - "
                end
              end
              t.add_row row
            end
          end
          rows_table.style = {:alignment => :center}
          puts "#{layer}\n#{rows_table}"
        end
      end
    end

    context "display seats layout table for Airbus Bus" do
      let(:records) {described_class.new(trip_id: phnom_penh_to_siem_reap_by_airbus.master.id, date: today)}
      it "return Air Bus seats layout" do
        result = records.call
        layout = result.layout
        expect(result.allow_seat_selection).to eq(true)
        expect(result.total_sold).to eq(7)
        puts "Total Seats: #{result.total_seats}"
        puts "Sold: #{result.total_sold}"
        puts "Remaining: #{result.remaining_seats}"
        layout.each do |layer, rows|
          rows_table = Terminal::Table.new do |t|
            rows.each do |row_num, seats|
              row = seats.map do |seat|
                if seat[:seat_type] == "normal"
                  seat[:seat_id] == nil ? " #{seat[:label]}" : "x#{seat[:label]}"
                else
                 seat[:seat_type] == "driver" ? "D   " : " - "
                end
              end
              t.add_row row
            end
          end
          rows_table.style = {:alignment => :center}
          puts "#{layer}\n#{rows_table}"
        end
      end
    end

    context "display seats layout table for ferry" do
      let(:records) {described_class.new(trip_id: sihanoukville_to_koh_rong_by_ferry.master.id, date: tomorrow)}
      it "return ferry seat layout" do
        result = records.call
        layout = result.layout
        puts "Total Seats: #{result.total_seats}"
        puts "Sold: #{result.total_sold}"
        puts "Remaining: #{result.remaining_seats}"
        puts "Allow Seat Selection: #{result.allow_seat_selection}"
        expect(result.allow_seat_selection).to eq(false)
        expect(result.layout).to eq(nil)
        expect(result.total_sold).to eq(5)
      end
    end

    context "display seats layout table for Minivan" do
      let(:records) {described_class.new(trip_id: phnom_penh_to_siem_reap_by_minivan.master.id, date: today)}
      it "return Minivan seats layout" do
        result = records.call
        layout = result.layout
        puts "Total Seats: #{result.total_seats}"
        puts "Sold: #{result.total_sold}"
        puts "Remaining: #{result.remaining_seats}"
        layout.each do |layer, rows|
          rows_table = Terminal::Table.new do |t|
            rows.each do |row_num, seats|
              row = seats.map do |seat|
                if seat[:seat_type] == "normal"
                  seat[:seat_id] == nil ? " #{seat[:label]}" : "x#{seat[:label]}"
                else
                 seat[:seat_type] == "driver" ? "D   " : " - "
                end
              end
              t.add_row row
            end
          end
          rows_table.style = {:alignment => :center}
          puts "#{layer}\n#{rows_table}"
        end
      end
    end
  end

  describe "#seats" do
    context "return all seats for sleeping bus" do
      let(:records) {described_class.new(trip_id: phnom_penh_to_siem_reap_by_sleeping_bus.master.id, date: today)}
      it "return all seats for  sleeping bus" do
        result = records.seats
        order_seats = [slb_f1_seat,slb_f2_seat,slb_s16_seat,slb_s17_seat]
        ordered_seats_from_result = result.select {|seat| seat.seat_id != nil}
        bookable_seats = result.select {|seat| %w[normal vip].include?(seat.seat_type)}
        available_seats = result.select {|seat| seat.seat_id == nil && %w[normal vip].include?(seat.seat_type)}
        expect(ordered_seats_from_result).to eq(order_seats)
        expect(bookable_seats.count).to eq(sleeping_bus.vehicle_seats_count)
        expect(available_seats.count).to eq(sleeping_bus.vehicle_seats_count - order_seats.count)
      end
    end
  end
  describe '#ordered_seats_sql' do
    context "return ordered seats for airbus" do
      let(:records) {described_class.new(trip_id: phnom_penh_to_siem_reap_by_airbus.master.id, date: today)}
      let(:failed_order) {create(:transit_order, variant: phnom_penh_to_siem_reap_by_airbus.master, seats: [arb_f2_seat,arb_f3_seat], date: today, state: 'payment', payment_state: nil)}
      it "return all seats for  sleeping bus" do
        result = records.ordered_seats
        ordered_seats_ids = result.pluck(:seat_id)
        expect(result.count).to eq(7)
        expect(ordered_seats_ids).not_to include [arb_f2_seat.id,arb_f3_seat.id]
      end
    end
  end
end
