require 'spec_helper'

RSpec.describe SpreeCmCommissioner::TripInventoryQuery do


  #vendor
  let!(:vet_airbus) { create(:vendor, name: 'Vet Airbus', code:"VET")}
  let!(:larryta)    { create(:vendor, name: 'Larryta', code: 'LTA')}
  let!(:buva_sea)   { create(:vendor, name:'Buva Sea', code:"BS")}

  #location
  let!(:phnom_penh)    { create(:cm_place, name: 'Phnom Penh') }
  let!(:siem_reap)     { create(:cm_place, name: 'Siem Reap') }
  let!(:sihanoukville) { create(:cm_place, name: 'Sihanoukville') }
  let!(:koh_rong)      { create(:cm_place, name: 'Koh Rong')}
  let!(:aeon2)         { create(:cm_place, name: 'Aeon Mall 2')}
  let!(:aeon1)         { create(:cm_place, name: 'Aeon Mall 1')}
  let!(:phsar_kandal)  { create(:cm_place, name: 'Phsar Kandal')}
  let!(:angkor_aquarium) { create(:cm_place, name: 'Angkor Aquarium')}
  let!(:angkor_wat)    { create(:cm_place, name: 'Angkor Wat')}

  #Vehicle Type
  let!(:airbus) { create(:vehicle_type,
                        :with_seats,
                        code: "AIRBUS",
                        vendor: vet_airbus,
                        row: 4,
                        column: 4)}

  let!(:minivan) { create(:vehicle_type,
                        :with_seats,
                        code: "minivan",
                        vendor: larryta,
                        row: 5,
                        column: 5)}

  let!(:ferry) { create(:vehicle_type,
                        code: 'ferry',
                        vendor: buva_sea,
                        allow_seat_selection: false,
                        vehicle_seats_count: 100
                        )}

  let!(:bus1)     {create(:vehicle, vehicle_type: airbus, vendor: vet_airbus)}
  let!(:bus2)     {create(:vehicle, vehicle_type: airbus, vendor: vet_airbus)}
  let!(:minivan1) {create(:vehicle, vehicle_type: minivan, vendor: larryta)}
  let!(:minivan2) {create(:vehicle, vehicle_type: minivan, vendor: larryta)}
  let!(:ferry1)   {create(:vehicle, vehicle_type: ferry, vendor: buva_sea)}
  let!(:ferry2)   {create(:vehicle, vehicle_type: ferry, vendor: buva_sea)}


  let!(:origin_option_type)         { create(:cm_option_type, :origin) }
  let!(:destination_option_type)    { create(:cm_option_type, :destination) }
  let!(:vehicle_option_type)        { create(:cm_option_type, :vehicle) }
  let!(:departure_time_option_type) { create(:cm_option_type, :departure_time) }
  let!(:duration_in_hours_option_type) { create(:cm_option_type, :duration_in_hours) }

  # Option Values Setup
  let!(:phnom_penh_ov)    { create(:cm_option_value, name: phnom_penh.id, option_type: origin_option_type) }
  let!(:siem_reap_ov)     { create(:cm_option_value, name: siem_reap.id, option_type: destination_option_type) }
  let!(:sihanoukville_ov) { create(:cm_option_value, name: sihanoukville.id, option_type: origin_option_type) }
  let!(:koh_rong_ov)      { create(:cm_option_value, name: koh_rong.id, option_type: destination_option_type) }
  let!(:bus1_ov)          { create(:cm_option_value, presentation: bus1.code, name: bus1.id, option_type: vehicle_option_type) }
  let!(:bus2_ov)          { create(:cm_option_value, presentation: bus2.code, name: bus2.id, option_type: vehicle_option_type) }
  let!(:minivan1_ov)      { create(:cm_option_value, presentation: minivan1.code, name: minivan1.id, option_type: vehicle_option_type) }
  let!(:minivan2_ov)      { create(:cm_option_value, presentation: minivan2.code, name: minivan2.id, option_type: vehicle_option_type) }
  let!(:ferry1_ov)        { create(:cm_option_value, presentation: ferry1.code, name: ferry1.id, option_type: vehicle_option_type) }
  let!(:ferry2_ov)        { create(:cm_option_value, presentation: ferry2.code, name: ferry2.id, option_type: vehicle_option_type) }

  # Departure Times
  let!(:departure_time_10am) { create(:cm_option_value, presentation: '10:00 AM', name: '10:00', option_type: departure_time_option_type) }
  let!(:departure_time_1pm) { create(:cm_option_value, presentation: '1:00 PM',  name: '13:00', option_type: departure_time_option_type) }
  let!(:departure_time_3pm) { create(:cm_option_value, presentation: '3:00 PM',  name: '15:00', option_type: departure_time_option_type) }
  let!(:departure_time_8pm) { create(:cm_option_value, presentation: '8:00 PM',  name: '20:00', option_type: departure_time_option_type) }

  # Durations (in hours and minutes)
  let!(:duration_5h)  { create(:cm_option_value, presentation: '5',  name: '5',  option_type: duration_in_hours_option_type) }
  let!(:duration_7h)  { create(:cm_option_value, presentation: '7',  name: '7',  option_type: duration_in_hours_option_type) }
  let!(:duration_4h)  { create(:cm_option_value, presentation: '4',  name: '4',  option_type: duration_in_hours_option_type) }
  let!(:duration_6h)  { create(:cm_option_value, presentation: '6',  name: '6',  option_type: duration_in_hours_option_type) }
  let!(:duration_3h)  { create(:cm_option_value, presentation: '3',  name: '3',  option_type: duration_in_hours_option_type) }

  # routes
  let!(:vet_phnom_penh_siem_reap)           { create(:route, name: 'VET-Air PP->SR', short_name: 'SR-PP',   vendor: vet_airbus) }
  let!(:larryta_phnom_penh_siemreap)        { create(:route, name: 'Larryta Airbus Phnom Penh Siem Reap', short_name: 'SR-PP',   vendor: larryta) }
  let!(:sihanoukville_to_koh_rong_by_ferry) { create(:route, name: 'Buva Sea Sihanoukville to Koh Rong', short_name: 'SR-PP',   vendor: buva_sea) }

  # variants
  let!(:vet_phnom_penh_siem_reap_1) do vet_phnom_penh_siem_reap.variants.create!(
      option_values: [
        phnom_penh_ov,
        siem_reap_ov,
        departure_time_10am,
        duration_6h,
        bus1_ov
      ],
      trip_stops_attributes:[
        {stop_id: aeon2.id, stop_type: "boarding"},
        {stop_id: phsar_kandal.id, stop_type: "boarding"},
        {stop_id: angkor_aquarium.id, stop_type: "drop_off"},
        {stop_id: angkor_wat.id, stop_type: "drop_off"},
      ],
      permanent_stock: bus1.number_of_seats,
    )
  end

  let!(:vet_phnom_penh_siem_reap_2) do vet_phnom_penh_siem_reap.variants.create!(
      option_values: [
        phnom_penh_ov,
        siem_reap_ov,
        departure_time_3pm,
        duration_7h,
        bus2_ov
      ],
      trip_stops_attributes:[
        {stop_id: aeon2.id, stop_type: "boarding"},
        {stop_id: phsar_kandal.id, stop_type: "boarding"},
        {stop_id: angkor_aquarium.id, stop_type: "drop_off"},

      ]
    )
  end
  let!(:larryta_phnom_penh_siemreap_1) do larryta_phnom_penh_siemreap.variants.create!(
      option_values: [
        phnom_penh_ov,
        siem_reap_ov,
        departure_time_1pm,
        duration_4h,
        minivan1_ov
      ],
      trip_stops_attributes:[
        {stop_id: aeon2.id, stop_type: "boarding"},
      ]
    )
  end

  let!(:larryta_phnom_penh_siemreap_2) do larryta_phnom_penh_siemreap.variants.create!(
      option_values: [
        phnom_penh_ov,
        siem_reap_ov,
        departure_time_8pm,
        duration_5h,
        minivan2_ov
      ],
      trip_stops_attributes:[
        {stop_id: angkor_wat.id, stop_type: "drop_off"},
      ]
    )
  end
  let!(:sihanoukville_to_koh_rong_by_ferry_1) do
    sihanoukville_to_koh_rong_by_ferry.variants.create!(
      option_values: [
        sihanoukville_ov,
        koh_rong_ov,
        departure_time_10am,
        duration_6h,
        ferry1_ov
      ],
      trip_stops_attributes: [
        { stop_id: sihanoukville.id, stop_type: "boarding" },
        { stop_id: koh_rong.id, stop_type: "drop_off" }
      ]
    )
  end

  let!(:sihanoukville_to_koh_rong_by_ferry_2) do sihanoukville_to_koh_rong_by_ferry.variants.create!(
      option_values: [
        sihanoukville_ov,
        koh_rong_ov,
        departure_time_3pm,
        duration_3h,
        ferry2_ov
      ],
      trip_stops_attributes:[
        {stop_id: sihanoukville.id, stop_type: "boarding"},
        {stop_id: koh_rong.id, stop_type: "drop_off"},
      ]
    )
  end

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

  # #minivan_seats
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
  let!(:order1) {create(:transit_order, variant: vet_phnom_penh_siem_reap_1, seats: [arb_f1_seat, arb_f2_seat, arb_f4_seat], date: today)}
  let!(:order2) {create(:transit_order, variant: vet_phnom_penh_siem_reap_1, seats: [arb_f5_seat, arb_f6_seat, arb_f7_seat, arb_f8_seat, arb_f9_seat], date: today)}
  let!(:order3) {create(:transit_order, variant: larryta_phnom_penh_siemreap_1, seats: [mvn_f1_seat, mvn_f2_seat], date: today)}
  let!(:order4) {create(:transit_order, variant: larryta_phnom_penh_siemreap_1, seats: [mvn_f3_seat, mvn_f4_seat], date: today)}
  let!(:order5) {create(:transit_order, variant: vet_phnom_penh_siem_reap_2,    seats: [arb_f1_seat, arb_f6_seat, arb_f4_seat], date: today)}
  let!(:failed_order1) {create(:transit_order, variant: vet_phnom_penh_siem_reap_2, seats: [arb_f2_seat, arb_f3_seat, arb_f5_seat], date: today, state: 'payment', payment_state: nil)}
  let!(:order6) {create(:transit_order, variant: larryta_phnom_penh_siemreap_2,     seats: [mvn_f7_seat, mvn_f8_seat], date: today)}
  let!(:order8) {create(:transit_order, variant: sihanoukville_to_koh_rong_by_ferry_1, date: tomorrow, quantity: 4)}

  let!(:variant_ids)   { [vet_phnom_penh_siem_reap_1.id, vet_phnom_penh_siem_reap_2.id,
                          larryta_phnom_penh_siemreap_1.id, larryta_phnom_penh_siemreap_2.id,
                          sihanoukville_to_koh_rong_by_ferry_1.id, sihanoukville_to_koh_rong_by_ferry_2.id
                          ] }
  let!(:today)         { Date.today }
  let!(:tomorrow)      { today + 1.day }
  let!(:vendor_id)     { nil }
  let!(:query)         { described_class.new(variant_ids: variant_ids, date: today, vendor_id: vendor_id) }


  describe '.call' do
    context 'when there are sold items' do
      let!(:result)         { described_class.new(variant_ids: variant_ids, date: today, vendor_id: vendor_id) }
      it 'returns the total sold for the given trip' do
        search_result =  result.call
        puts 'vet_phnom_penh_siem_reap_1', vet_phnom_penh_siem_reap_1.id
        puts 'larryta_phnom_penh_siemreap_1', larryta_phnom_penh_siemreap_1.id
        search_result.each do |v|
          puts 'trip_id ', v[:id]
          puts 'total sold', v[:total_sold]
          puts 'total seats', v[:total_seats]
        end
        puts order1.inspect
      end
    end

    context "return sold result of SV-KR for tomorrow " do
      let(:result) { described_class.new(variant_ids: variant_ids, date: tomorrow) }
      it "return sold result for today" do
        search_result = result.call.sort_by(&:id)
        puts search_result.count
        expect(search_result.first.total_seats - search_result.first.total_sold).to eq(96)
      end
    end
  end
end