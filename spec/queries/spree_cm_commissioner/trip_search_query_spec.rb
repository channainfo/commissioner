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
                        column: 4,)}

  let!(:minivan) {create(:vehicle_type,
                        :with_seats,
                        code: "minivan",
                        vendor: larryta,
                        row: 5,
                        column: 5,)}

  let!(:bus1) {create(:vehicle, vehicle_type: airbus, vendor: vet_airbus)}
  let!(:bus2) {create(:vehicle, vehicle_type: airbus, vendor_id: vet_airbus)}
  let!(:minivan1) {create(:vehicle, vehicle_type: minivan, vendor: larryta)}
  let!(:minivan2) {create(:vehicle, vehicle_type: minivan, vendor: larryta)}

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
                                                vehicle_id: Spree::OptionType.vehicle,
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
                                                    vehicle_id: Spree::OptionType.vehicle,
                                                    vehicle_id: minivan1.id) }

  let!(:vet_pp_to_sr_trip_1) {create(:trip,
                                  route: phnom_penh_to_siem_reap_by_vet,
                                  sku: 'VET-PP-SR-10:00-6',
                                  departure_time: dt_10,
                                  duration: duration_6,
                                  vehicle_id: bus1.id
                                  )}

  let!(:vet_pp_to_sr_trip_2) {create(:trip,
                                    route: phnom_penh_to_siem_reap_by_vet,
                                    sku: 'VET-PP-SR-13:00-5',
                                    departure_time: dt_13,
                                    duration: duration_5,
                                    vehicle_id: bus2.id
                                    )}

  let!(:larryta_pp_to_sr_trip_1) {create(:trip,
                                        route: phnom_penh_to_siem_reap_by_larryta,
                                        sku: 'LTA-PP-SR-13:00-6',
                                        departure_time: dt_13,
                                        duration: duration_3,
                                        vehicle_id: minivan1.id
                                        )}

  let!(:larryta_pp_to_sr_trip_2) {create(:trip,
                                        route: phnom_penh_to_siem_reap_by_larryta,
                                        sku: 'LTA-PP-SR-20:00-7',
                                        departure_time: dt_20,
                                        duration: duration_7,
                                        vehicle_id: minivan2.id
                                        )}
#date
let!(:today) {Date.today}
let!(:tomorrow) {today + 1.day}

#airbus_seats
  let!(:arb_f1_seat) {airbus.vehicle_seats.find_by(row: 1, column: 1)}
  let!(:arb_f2_seat) {airbus.vehicle_seats.find_by(row: 1, column: 2)}
  let!(:arb_f3_seat) {airbus.vehicle_seats.find_by(row: 1, column: 3)}
  let!(:arb_f4_seat) {airbus.vehicle_seats.find_by(row: 1, column: 4)}
  let!(:arb_f5_seat) {airbus.vehicle_seats.find_by(row: 2, column: 1)}
  let!(:arb_f6_seat) {airbus.vehicle_seats.find_by(row: 2, column: 2)}
  let!(:arb_f7_seat) {airbus.vehicle_seats.find_by(row: 2, column: 3)}
  let!(:arb_f8_seat) {airbus.vehicle_seats.find_by(row: 2, column: 4)}
  let!(:arb_f9_seat) {airbus.vehicle_seats.find_by(row: 3, column: 1)}

  #minivan_seats
  let!(:mvn_f1_seat) {minivan.vehicle_seats.find_by(row: 1, column: 1)}
  let!(:mvn_f2_seat) {minivan.vehicle_seats.find_by(row: 1, column: 2)}
  let!(:mvn_f3_seat) {minivan.vehicle_seats.find_by(row: 1, column: 3)}
  let!(:mvn_f4_seat) {minivan.vehicle_seats.find_by(row: 1, column: 4)}
  let!(:mvn_f5_seat) {minivan.vehicle_seats.find_by(row: 2, column: 1)}
  let!(:mvn_f6_seat) {minivan.vehicle_seats.find_by(row: 2, column: 2)}
  let!(:mvn_f7_seat) {minivan.vehicle_seats.find_by(row: 1, column: 3)}
  let!(:mvn_f8_seat) {minivan.vehicle_seats.find_by(row: 1, column: 4)}
  let!(:mvn_f9_seat) {minivan.vehicle_seats.find_by(row: 3, column: 1)}



  #order
  let!(:order1) {create(:transit_order, variant: vet_pp_to_sr_trip_1, seats: [arb_f1_seat,arb_f2_seat,arb_f4_seat], date: today)}
  let!(:order2) {create(:transit_order, variant: vet_pp_to_sr_trip_1, seats: [arb_f5_seat,arb_f6_seat,arb_f7_seat,arb_f8_seat,arb_f9_seat], date: today)}
  let!(:order3) {create(:transit_order, variant: vet_pp_to_sr_trip_2, seats: [arb_f1_seat,arb_f2_seat], date: today)}
  let!(:order4) {create(:transit_order, variant: vet_pp_to_sr_trip_2, seats: [arb_f7_seat,arb_f8_seat], date: today)}
  let!(:order5) {create(:transit_order, variant: larryta_pp_to_sr_trip_1, seats: [mvn_f1_seat,mvn_f2_seat], date: today)}
  let!(:order6) {create(:transit_order, variant: larryta_pp_to_sr_trip_2, seats: [mvn_f3_seat,mvn_f4_seat], date: today)}




  describe"#trip_info" do
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
                        r['remaining_seats'], r['attr_type'], r['option_value']]
          table.add_separator unless r.equal?(result.last) # Avoid adding separator after the last row
        end

        puts table
      end
    end
  end

  describe"#process" do
    context "display table" do
      let(:result) {described_class.new(origin_id: phnom_penh, destination_id: siem_reap, date: today)}
      it "return trips table" do
        search_result =  result.trips_info
        search_result = result.process(search_result)
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
  end
end
