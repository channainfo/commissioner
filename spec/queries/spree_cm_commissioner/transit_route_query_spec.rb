require 'spec_helper'

RSpec.describe SpreeCmCommissioner::TransitRouteQuery do
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
                        row: 4,
                        column: 4,)}

  let!(:bus1) {create(:vehicle, vehicle_type: airbus, vendor: vet_airbus)}
  let!(:bus2) {create(:vehicle, vehicle_type: airbus, vendor_id: vet_airbus)}
  let!(:minivan1) {create(:vehicle, vehicle_type: minivan, vendor: larryta)}
  let!(:minivan2) {create(:vehicle, vehicle_type: minivan, vendor: larryta)}
  #routes
  let!(:phnom_penh_to_siem_reap_by_vet) { create(:route,
                                                name: 'Phnom Penh to Siem Reap by Vet Airbus',
                                                short_name:"PP-SR",
                                                vendor: vet_airbus,
                                                origin_id: phnom_penh.id,
                                                destination_id: siem_reap.id) }

  let!(:phnom_penh_to_siem_reap_by_larryta) { create(:route,
                                                    name: 'Phnom Penh to Siem Reap by Larryta',
                                                    short_name:"PP-SR",
                                                    vendor: larryta,
                                                    origin_id: phnom_penh.id,
                                                    destination_id: siem_reap.id) }

  let!(:vet_pp_to_sr_trip_1) {create(:trip,
                                  route: phnom_penh_to_siem_reap_by_vet,
                                  sku: 'VET-PP-SR-13:00-6',
                                  departure_time: '13:00',
                                  duration: '6',
                                  vehicle: bus1)}

  let!(:vet_pp_to_sr_trip_2) {create(:trip,
                                    route: phnom_penh_to_siem_reap_by_vet,
                                    sku: 'VET-PP-SR-13:00-5',
                                    departure_time: '13:00',
                                    duration: '5',
                                    vehicle: bus2)}
  let!(:larryta_pp_to_sr_trip_1) {create(:trip,
                                        route: phnom_penh_to_siem_reap_by_larryta,
                                        sku: 'LTA-PP-SR-13:00-6',
                                        departure_time: '13:00',
                                        duration: '6',
                                        vehicle: minivan1)}
  let!(:larryta_pp_to_sr_trip_2) {create(:trip,
                                        route: phnom_penh_to_siem_reap_by_larryta,
                                        sku: 'LTA-PP-SR-14:00-7',
                                        departure_time: '14:00',
                                        duration: '7',
                                        vehicle: minivan2)}
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




  describe"#trips" do
    context "display table" do
      let(:records) {described_class.new(origin_id: phnom_penh, destination_id: siem_reap, date: tomorrow)}
      it "return trips table" do
        # result =  SpreeCmCommissioner::TransitRouteQuery.call(origin_id: phnom_penh, destination_id: siem_reap, date: today)
        # p result.map(&:attributes)
        result =  records.call.to_a
        table = Terminal::Table.new :headings => ['Trip ID', 'Name', 'Origin', 'Destination', 'Vehicle ID', 'Vendor', 'Total Seat', 'Total Sold', 'Remaining Seats']

        result.each do |r|
          table.add_row [r["trip_id"], r["route_name"], r["origin"], r["destination"], r["vehicle_id"], r["vendor_name"], r["total_seats"], r['total_sold'], r['remaining_seats']]
          table.add_separator unless r.equal?(result.last) # Avoid adding separator after the last row
        end

        puts table
      end
    end
    context"trip from phnom-penh to siem-reap by vet_airbus" do
      let(:records) {described_class.new(origin_id: phnom_penh.id, destination_id: siem_reap.id, date: today, vendor_id: vet_airbus)}
      it "return matching trips by vet_airbus" do
        result = records.trips.to_a
        expect(result.count).to eq(2)
        expect(result.first["id"]).to eq(vet_pp_to_sr_trip_1.id)
        expect(result.last["id"]).to eq(vet_pp_to_sr_trip_2.id)
      end
    end
    context"trip from phnom-penh to siem-reap by larryta" do
      let(:records) {described_class.new(origin_id: phnom_penh.id, destination_id: siem_reap.id, date: today, vendor_id: larryta)}
      it "return matching trips by vet_airbus" do
        result = records.trips.to_a
        expect(result.count).to eq(2)
        expect(result.first["id"]).to eq(larryta_pp_to_sr_trip_1.id)
        expect(result.last["id"]).to eq(larryta_pp_to_sr_trip_2.id)
      end
    end
    context"trip from phnom-penh to sihanoukville" do
      let(:mekong_expess) {create(:vendor, name: 'Mekong Express', code: 'MEK')}
      let(:records) {described_class.new(origin_id: phnom_penh.id, destination_id: siem_reap.id, date: today, vendor_id: mekong_expess)}
      it "return no matching trips" do
        result = records.trips.to_a
        expect(result.count).to eq(0)
        expect(result).to eq([])
      end
    end
  end

  describe"#matching_trips" do
    context"trip from phnom-penh to siem-reap " do
      let(:records) {described_class.new(origin_id: phnom_penh.id, destination_id: siem_reap.id, date: today)}
      it"return matching trips" do
        result = records.matching_trips.to_a
        expect(result.count).to eq(4)
        expect(result[0]["id"]).to eq(vet_pp_to_sr_trip_1.id)
        expect(result[1]["id"]).to eq(vet_pp_to_sr_trip_2.id)
        expect(result[2]["id"]).to eq(larryta_pp_to_sr_trip_1.id)
        expect(result[3]["id"]).to eq(larryta_pp_to_sr_trip_2.id)
      end
    end

    context"trip from phnom-penh to sihanoukville" do
      let(:records) {described_class.new(origin_id: phnom_penh.id, destination_id: sihanoukville.id, date: today)}
      it "return no matching trips" do
        result = records.matching_trips.to_a
        expect(result.count).to eq(0)
        expect(result).to eq([])
      end
    end
  end

  describe"#trip_remaining_seats" do
    context "remaining seats for today" do
      let(:records) {described_class.new(origin_id: phnom_penh.id, destination_id: siem_reap.id, date: today)}
      it "return today's remaining seats" do
          result = records.trip_remaining_seats.map { |trip| { "id" => trip.id, "remaining_seats" => trip.remaining_seats } }
          expect(result).to include({"id"=>vet_pp_to_sr_trip_1.id, "remaining_seats"=>8})
          expect(result).to include({"id"=>vet_pp_to_sr_trip_2.id, "remaining_seats"=>12})
          expect(result).to include({"id"=>larryta_pp_to_sr_trip_1.id, "remaining_seats"=>14})
          expect(result).to include({"id"=>larryta_pp_to_sr_trip_2.id, "remaining_seats"=>14})
        end
    end
    context "remaining seats for tomorrow" do
      let!(:tmr_order_1) {create(:transit_order, variant: vet_pp_to_sr_trip_1, seats: [arb_f1_seat,arb_f2_seat,arb_f4_seat], date: tomorrow)}
      let!(:tmr_order_2) {create(:transit_order, variant: larryta_pp_to_sr_trip_1, seats: [mvn_f5_seat,mvn_f6_seat,mvn_f7_seat,mvn_f8_seat,mvn_f9_seat], date: tomorrow)}
      let(:records) {described_class.new(origin_id: phnom_penh.id, destination_id: siem_reap.id, date: tomorrow)}
      it "return tomorrow's remaining seats" do
        result = records.trip_remaining_seats.map { |trip| { "id" => trip.id, "remaining_seats" => trip.remaining_seats } }
        expect(result).to include({"id"=>vet_pp_to_sr_trip_1.id, "remaining_seats"=>13})
        expect(result).to include({"id"=>vet_pp_to_sr_trip_2.id, "remaining_seats"=>16})
        expect(result).to include({"id"=>larryta_pp_to_sr_trip_1.id, "remaining_seats"=>11})
        expect(result).to include({"id"=>larryta_pp_to_sr_trip_2.id, "remaining_seats"=>16})
      end
    end
  end
end
