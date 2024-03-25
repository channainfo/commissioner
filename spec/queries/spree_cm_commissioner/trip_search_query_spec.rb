require 'spec_helper'

RSpec.describe SpreeCmCommissioner::TripSearchQuery do
  #vendor
  let!(:vet_airbus) {create(:vendor, name: 'Vet Airbus', code:"VET")}
  let!(:larryta) {create(:vendor, name: 'Larryta', code: 'LTA')}
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
                        vendor: vet_airbus,
                        row: 4,
                        column: 4)}

  let!(:minivan) {create(:vehicle_type,
                        :with_seats,
                        code: "minivan",
                        vendor: larryta,
                        row: 5,
                        column: 5)}

  let!(:ferry) {create(:vehicle_type,
                        code: 'ferry',
                        vendor: buva_sea,
                        allow_seat_selection: false,
                        vehicle_seats_count: 100
                        )}

  let!(:bus1) {create(:vehicle, vehicle_type: airbus, vendor: vet_airbus)}
  let!(:bus2) {create(:vehicle, vehicle_type: airbus, vendor: vet_airbus)}
  let!(:minivan1) {create(:vehicle, vehicle_type: minivan, vendor: larryta)}
  let!(:minivan2) {create(:vehicle, vehicle_type: minivan, vendor: larryta)}
  let!(:ferry1) {create(:vehicle, vehicle_type: ferry, vendor: buva_sea)}
  let!(:ferry2) {create(:vehicle, vehicle_type: ferry, vendor: buva_sea)}

  #routes
  let!(:vet_phnom_penh_siem_reap_1) { create(:route,
                                                trip_attributes: {
                                                  origin_id: phnom_penh.id,
                                                  destination_id: siem_reap.id,
                                                  departure_time: '10:00',
                                                  duration: 21660,
                                                  vehicle_id: bus1.id
                                                },
                                                name: 'VET Airbus Phnom Penh Siem Reap 10:00',
                                                short_name:"PP-SR-10:00-6",
                                                vendor: vet_airbus
                                                ) }
  let!(:vet_phnom_penh_siem_reap_2) { create(:route,
                                                trip_attributes: {
                                                  origin_id: phnom_penh.id,
                                                  destination_id: siem_reap.id,
                                                  departure_time: '15:00',
                                                  duration: 25200,
                                                  vehicle_id: bus2.id
                                                },
                                                name: 'VET Airbus Phnom Penh Siem Reap 15:00',
                                                short_name:"PP-SR-15:00-7",
                                                vendor: vet_airbus
                                              ) }

  let!(:larryta_phnom_penh_siemreap_1) { create(:route,
                                                    trip_attributes: {
                                                      origin_id: phnom_penh.id,
                                                      destination_id: siem_reap.id,
                                                      departure_time: '13:00',
                                                      duration: 14400,
                                                      vehicle_id: minivan1.id
                                                    },
                                                    name: 'Larryta Airbus Phnom Penh Siem Reap 13:00',
                                                    short_name:"PP-SR-13:00-4",
                                                    vendor: larryta
                                                    ) }

  let!(:larryta_phnom_penh_siemreap_2) { create(:route,
                                                    trip_attributes: {
                                                      origin_id: phnom_penh.id,
                                                      destination_id: siem_reap.id,
                                                      departure_time: '20:00',
                                                      duration: 18000,
                                                      vehicle_id: minivan2.id
                                                    },
                                                    name: 'Larryta Airbus Phnom Penh Siem Reap 20:00',
                                                    short_name:"PP-SR-20:00-5",
                                                    vendor: larryta
                                                    ) }
  let!(:sihanoukville_to_koh_rong_by_ferry) {create(:route,
                                                    trip_attributes: {
                                                      origin_id: sihanoukville.id,
                                                      destination_id: koh_rong.id,
                                                      departure_time: '10:00',
                                                      duration: 21600,
                                                      vehicle_id: ferry1.id,
                                                      allow_seat_selection: false
                                                    },
                                                    name: "Buva Sea Sihanoukville to Koh Rong 10",
                                                    short_name: "SV-KR10-00-6",
                                                    vendor: buva_sea)}

  let!(:sihanoukville_to_koh_rong_by_ferry_2) {create(:route,
                                                    trip_attributes: {
                                                      origin_id: sihanoukville.id,
                                                      destination_id: koh_rong.id,
                                                      departure_time: '15:00',
                                                      duration: 10800,
                                                      vehicle_id: ferry2.id,
                                                      allow_seat_selection: false
                                                    },
                                                    name: "Buva Sea Sihanoukville to Koh Rong 15",
                                                    short_name: "SV-KR-15-00-3",
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
  let!(:order1) {create(:transit_order, variant: vet_phnom_penh_siem_reap_1.master, seats: [arb_f1_seat,arb_f2_seat,arb_f4_seat], date: today)}
  let!(:order2) {create(:transit_order, variant: vet_phnom_penh_siem_reap_1.master, seats: [arb_f5_seat,arb_f6_seat,arb_f7_seat,arb_f8_seat,arb_f9_seat], date: today)}
  let!(:order3) {create(:transit_order, variant: larryta_phnom_penh_siemreap_1.master, seats: [mvn_f1_seat,mvn_f2_seat], date: today)}
  let!(:order4) {create(:transit_order, variant: larryta_phnom_penh_siemreap_1.master, seats: [mvn_f3_seat,mvn_f4_seat], date: today)}
  let!(:order5) {create(:transit_order, variant: vet_phnom_penh_siem_reap_2.master, seats: [arb_f1_seat,arb_f6_seat,arb_f4_seat], date: today)}
  let!(:failed_order1) {create(:transit_order, variant: vet_phnom_penh_siem_reap_2.master, seats: [arb_f2_seat,arb_f3_seat,arb_f5_seat], date: today, state: 'payment', payment_state: nil)}
  let!(:order6) {create(:transit_order, variant: larryta_phnom_penh_siemreap_2.master, seats: [mvn_f7_seat,mvn_f8_seat], date: today)}
  let!(:order8) {create(:transit_order, variant: sihanoukville_to_koh_rong_by_ferry.master, date: tomorrow, quantity: 4)}

  describe"#trips_info" do
    context "display table" do
      let(:records) {described_class.new(origin_id: phnom_penh, destination_id: siem_reap, date: today)}
      it "return trips table" do
        result =  records.trips_info
        table = Terminal::Table.new :headings => ['Trip ID', 'Name', 'Vendor', 'Short Name',
                                                  'Origin', 'Destination', 'Total Seat',
                                                  'Total Sold', 'Remaining Seats', 'Departure Time', 'Duration', 'Vehicle']

        result.each do |r|
          table.add_row [r["trip_id"], r["route_name"], r["vendor_name"], r['short_name'],
                        r["origin"] + " - " + r['origin_id'].to_s, r["destination"] +" - " +r['destination_id'].to_s, r["total_seats"], r['total_sold'],
                        r['total_seats'] - r['total_sold'], r['departure_time'].strftime("%H:%M"), r['duration'], r['vehicle_id']]
          table.add_separator unless r.equal?(result.last) # Avoid adding separator after the last row
        end
        table.style = {:alignment => :center}
        puts table
      end
    end

    context "without vendor context" do
      let(:result) {described_class.new(origin_id: phnom_penh, destination_id: siem_reap, date: today)}
      it "return all matching trip" do
        search_result = result.trips_info.to_a.sort_by(&:trip_id)
        expect(search_result.count).to eq(4)
        expect(search_result.first["vendor_name"]).to eq("Vet Airbus")
        expect(search_result.last["vendor_name"]).to eq("Larryta")
      end
    end

    context "with vendor context" do
      let(:result) {described_class.new(origin_id: phnom_penh, destination_id: siem_reap, date: today, vendor_id: vet_airbus.id)}
      it "return only vet-airbus's trip " do
        search_result = result.trips_info.to_a.sort_by(&:trip_id)
        expect(search_result.count).to eq(2)
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
        table = Terminal::Table.new :headings => ['Trip ID', 'Name', 'Vendor', 'Short Name',
                                                  'Origin', 'Destination', 'Departure Time', 'Arrival Time',
                                                  'Duration', 'Vehicle' , 'Total Seat',
                                                  'Sold', 'Remaining Seats']
        search_result.each do |r|
          table.add_row [r.trip_id, r.route_name, r.vendor_name, r.short_name,
                          r.origin + " - " + r.origin_id.to_s, r.destination + " - " + r.destination_id.to_s, r.departure_time,
                          r.arrival_time, r.duration_in_hms, r.vehicle_id, r.total_seats, r.total_sold, r.remaining_seats]
          table.add_separator unless r.equal?(search_result.last) # Avoid adding separator after the last row
        end
        table.style = {:alignment => :center}
        puts table
      end
    end

    context "return trip result for today" do
      let(:result) {described_class.new(origin_id: phnom_penh, destination_id: siem_reap, date: today)}
      it "return trip result for today" do
        search_result = result.call.sort_by(&:trip_id)
        expect(search_result.count).to eq(4)
        expect(search_result.first.remaining_seats).to eq(7)
        expect(search_result[1].remaining_seats).to eq(12)
        expect(search_result[2].remaining_seats).to eq(20)
        expect(search_result.last.remaining_seats).to eq(22)
      end
    end
    context "return trip result of SV-KR for tomorrow " do
      let(:result) {described_class.new(origin_id: sihanoukville, destination_id: koh_rong, date: tomorrow)}
      it "return trip result for today" do
        search_result = result.call.sort_by(&:trip_id)
        expect(search_result.count).to eq(2)
        expect(search_result.first.remaining_seats).to eq(96)
        expect(search_result.last.remaining_seats).to eq(100)
      end
    end
    context "return trip result for tomorrow" do
      let(:result) {described_class.new(origin_id: phnom_penh, destination_id: siem_reap, date: tomorrow)}
      let!(:tmr_order1) {create(:transit_order, variant: vet_phnom_penh_siem_reap_1.master, seats: [arb_f1_seat,arb_f2_seat,arb_f4_seat], date: tomorrow)}
      let!(:tmr_order2) {create(:transit_order, variant: larryta_phnom_penh_siemreap_2.master, seats: [mvn_f3_seat,mvn_f4_seat], date: tomorrow)}
      it "return trip result for tomorrow" do
        search_result = result.call.sort_by(&:trip_id)
        expect(search_result.count).to eq(4)
        expect(search_result.first.remaining_seats).to eq(12)
        expect(search_result[1].remaining_seats).to eq(15)
        expect(search_result[2].remaining_seats).to eq(24)
        expect(search_result.last.remaining_seats).to eq(22)
      end
    end
  end
end
