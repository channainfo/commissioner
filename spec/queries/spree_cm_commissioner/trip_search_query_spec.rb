require 'spec_helper'

RSpec.describe SpreeCmCommissioner::TripSearchQuery do
  #vendor
  let!(:vet_airbus) {create(:vendor, name: 'Vet Airbus', code:"VET")}
  let!(:larryta) {create(:vendor, name: 'Larryta', code: 'LTA')}

  #location
  let!(:phnom_penh) { create(:transit_place, name: 'Phnom Penh', data_type:4) }
  let!(:siem_reap) { create(:transit_place, name: 'Siem Reap', data_type:4) }
  let!(:sihanoukville) { create(:transit_place, name: 'Sihanoukville', data_type:4) }

  #Vehicle Type
  let!(:airbus) {create(:vehicle_type,
                        :with_seats,
                        code: "AIRBUS",
                        vendor: vet_airbus,
                        row: 4,
                        column: 4)}

  let!(:minivan) {create(:vehicle_type,
                        :with_seats,
                        code: "minivan",
                        vendor: larryta,
                        row: 5,
                        column: 5)}

  let!(:bus1) {create(:vehicle, vehicle_type: airbus, vendor: vet_airbus)}
  let!(:minivan1) {create(:vehicle, vehicle_type: minivan, vendor: larryta)}

  #option_type
  let!(:duration) {create(:option_type, name: 'duration', presentation: 'Duration', attr_type: 'duration', kind: 'variant')}
  let!(:departure_time) {create(:option_type, name: 'departure_time', presentation: 'Departure Time', attr_type: 'departure_time', kind: 'variant')}
#option_value
  let!(:dt_13) {create(:option_value, name: '13:00', presentation: '13:00', option_type: departure_time)}
  let!(:dt_10) {create(:option_value, name: '10:00', presentation: '10:00', option_type: departure_time)}
  let(:dt_20) {create(:option_value, name: '20:00', presentation: '20:00', option_type: departure_time)}
  let(:duration_6) {create(:option_value, name: '6', presentation: '6', option_type: duration)}
  let(:duration_5) {create(:option_value, name: '5', presentation: '5', option_type: duration)}
  let(:duration_3) {create(:option_value, name: '3', presentation: '3', option_type: duration)}
  let(:duration_7) {create(:option_value, name: '7', presentation: '7', option_type: duration)}


  #routes
  let!(:phnom_penh_to_siem_reap_by_vet) { create(:route,
                                                :with_option_types,
                                                name: 'Phnom Penh to Siem Reap by Vet Airbus',
                                                short_name:"PP-SR",
                                                vendor: vet_airbus,
                                                origin_id: phnom_penh.id,
                                                destination_id: siem_reap.id,
                                                departure_time: departure_time,
                                                duration: duration,
                                                vehicle_id: bus1.id) }

  let!(:phnom_penh_to_siem_reap_by_larryta) { create(:route,
                                                    :with_option_types,
                                                    name: 'Phnom Penh to Siem Reap by Larryta',
                                                    short_name:"PP-SR",
                                                    vendor: larryta,
                                                    origin_id: phnom_penh.id,
                                                    destination_id: siem_reap.id,
                                                    departure_time: departure_time,
                                                    duration: duration,
                                                    vehicle_id: minivan1.id) }

  let!(:vet_pp_to_sr_trip_1) {create(:trip,
                                  route: phnom_penh_to_siem_reap_by_vet,
                                  sku: 'VET-PP-SR-10:00-6',
                                  departure_time: dt_10,
                                  duration: duration_6
                                  )}

  let!(:vet_pp_to_sr_trip_2) {create(:trip,
                                    route: phnom_penh_to_siem_reap_by_vet,
                                    sku: 'VET-PP-SR-13:00-5',
                                    departure_time: dt_13,
                                    duration: duration_5
                                    )}

  let!(:larryta_pp_to_sr_trip_1) {create(:trip,
                                        route: phnom_penh_to_siem_reap_by_larryta,
                                        sku: 'LTA-PP-SR-13:00-6',
                                        departure_time: dt_13,
                                        duration: duration_3,
                                        )}

  let!(:larryta_pp_to_sr_trip_2) {create(:trip,
                                        route: phnom_penh_to_siem_reap_by_larryta,
                                        sku: 'LTA-PP-SR-20:00-7',
                                        departure_time: dt_20,
                                        duration: duration_7,
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
  let!(:order1) {create(:transit_order, variant: vet_pp_to_sr_trip_1, seats: [arb_f1_seat,arb_f2_seat,arb_f4_seat], date: today)}
  let!(:order2) {create(:transit_order, variant: vet_pp_to_sr_trip_1, seats: [arb_f5_seat,arb_f6_seat,arb_f7_seat,arb_f8_seat,arb_f9_seat], date: today)}
  let!(:order3) {create(:transit_order, variant: vet_pp_to_sr_trip_2, seats: [arb_f1_seat,arb_f2_seat], date: today)}
  let!(:order4) {create(:transit_order, variant: vet_pp_to_sr_trip_2, seats: [arb_f7_seat,arb_f8_seat], date: today)}
  let!(:order5) {create(:transit_order, variant: larryta_pp_to_sr_trip_1, seats: [mvn_f1_seat,mvn_f2_seat], date: today)}
  let!(:order6) {create(:transit_order, variant: larryta_pp_to_sr_trip_2, seats: [mvn_f3_seat,mvn_f4_seat], date: today)}




  describe"#trips_info" do
    context "display table" do
      let(:records) {described_class.new(origin_id: phnom_penh, destination_id: siem_reap, date: today)}
      it "return trips table" do
        result =  records.trips_info
        table = Terminal::Table.new :headings => ['Trip ID', 'Name', 'Vendor',
                                                  'Origin', 'Destination', 'Total Seat',
                                                  'Total Sold', 'Remaining Seats', 'Attr Type', 'Option Value',]

        result.each do |r|
          table.add_row [r["trip_id"], r["route_name"], r["vendor_name"],
                        r["origin"], r["destination"], r["total_seats"], r['total_sold'],
                        r['total_seats'] - r['total_sold'], r['attr_type'], r['option_value']]
          table.add_separator unless r.equal?(result.last) # Avoid adding separator after the last row
        end

        puts table
      end
    end

    context "without vendor context" do
      let(:result) {described_class.new(origin_id: phnom_penh, destination_id: siem_reap, date: today)}
      it "return all matching trip" do
        search_result = result.trips_info.to_a.sort_by(&:trip_id)
        expect(search_result.count).to eq(8)
        expect(search_result.first["vendor_name"]).to eq("Vet Airbus")
        expect(search_result.last["vendor_name"]).to eq("Larryta")
      end
    end

    context "with vendor context" do
      let(:result) {described_class.new(origin_id: phnom_penh, destination_id: siem_reap, date: today, vendor_id: vet_airbus.id)}
      it "return only vet-airbus's trip " do
        search_result = result.trips_info.to_a.sort_by(&:trip_id)
        expect(search_result.count).to eq(4)
        expect(search_result.first["vendor_name"]).to eq("Vet Airbus")
        expect(search_result.last["vendor_name"]).to eq("Vet Airbus")
      end
    end

    context "no matching trip" do
      let(:result) {described_class.new(origin_id: phnom_penh, destination_id: sihanoukville, date: today)}
      it " return empty array" do
        search_result = result.trips_info.to_a
        expect(search_result.count).to eq(0)
      end
    end
  end

  describe"#call" do
    context "display table" do
      let(:result) {described_class.new(origin_id: phnom_penh, destination_id: siem_reap, date: today)}
      it "return trips table" do
        search_result = result.call.sort_by(&:trip_id)
        table = Terminal::Table.new :headings => ['Trip ID', 'Name', 'Vendor',
                                                  'Origin', 'Destination', 'Departure Time', 'Arrival Time',
                                                  'Duration', 'Vehicle ID' , 'Total Seat',
                                                  'Total Sold', 'Remaining Seats']
        search_result.each do |r|
          table.add_row [r.trip_id, r.route_name, r.vendor_name,
                          r.origin + " - " + r.origin_id.to_s, r.destination + " - " + r.destination_id.to_s, r.departure_time,
                          r.arrival_time, r.duration, r.vehicle_id, r.total_seats, r.total_sold, r.remaining_seats]
          table.add_separator unless r.equal?(search_result.last) # Avoid adding separator after the last row
        end

        puts table
      end
    end

    context "return trip result for today" do
      let(:result) {described_class.new(origin_id: phnom_penh, destination_id: siem_reap, date: today)}
      it "return trip result for today" do
        search_result = result.call.sort_by(&:trip_id)
        expect(search_result.count).to eq(4)
        expect(search_result.first.trip_id).to eq(vet_pp_to_sr_trip_1.id)
        expect(search_result.last.trip_id).to eq(larryta_pp_to_sr_trip_2.id)
        expect(search_result.first.remaining_seats).to eq(7)
        expect(search_result.last.remaining_seats).to eq(22)
      end
    end
    context "return trip result for tomorrow" do
      let(:result) {described_class.new(origin_id: phnom_penh, destination_id: siem_reap, date: tomorrow)}
      let!(:tmr_order1) {create(:transit_order, variant: vet_pp_to_sr_trip_1, seats: [arb_f1_seat,arb_f2_seat,arb_f4_seat], date: tomorrow)}
      let!(:tmr_order2) {create(:transit_order, variant: larryta_pp_to_sr_trip_2, seats: [mvn_f3_seat,mvn_f4_seat], date: tomorrow)}
      it "return trip result for tomorrow" do
        search_result = result.call.sort_by(&:trip_id)
        expect(search_result.count).to eq(4)
        expect(search_result.first.remaining_seats).to eq(12)
        expect(search_result.last.remaining_seats).to eq(22)
      end
    end
  end
end
