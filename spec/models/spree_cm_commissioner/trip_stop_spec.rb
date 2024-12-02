require 'spec_helper'

RSpec.describe SpreeCmCommissioner::TripStop, type: :model do
  let!(:vet_airbus) {create(:vendor, name: 'Vet Airbus', code:"VET")}
  let!(:larryta) {create(:vendor, name: 'Larryta', code: 'LTA')}

  #location
  let!(:phnom_penh) { create(:transit_place, name: 'Phnom Penh', data_type:8) }
  let!(:siem_reap) { create(:transit_place, name: 'Siem Reap', data_type:8) }
  let!(:sihanoukville) { create(:transit_place, name: 'Sihanoukville', data_type:8) }
  let!(:aeon1) {create(:transit_place, name: 'Aeon Mall 1', data_type:1)}
  let!(:angkor_wat) {create(:transit_place, name: 'Angkor Wat', data_type:1)}

  #Vehicle
  let!(:airbus) {create(:vehicle_type,
  :with_seats,
  code: "AIRBUS",
  vendor: vet_airbus,
  row: 4,
  column: 4)}
  let!(:bus1) {create(:vehicle, vehicle_type: airbus, vendor: vet_airbus)}

  let!(:vet_phnom_penh_siem_reap) { create(:route, name: 'VET Airbus Phnom Penh Siem Reap 10:00', short_name:"PP-SR-10:00-6", vendor: vet_airbus ) }
  let!(:vet_phnom_penh_sihanoukville) { create(:route,name: 'VET Airbus Phnom Penh Sihanoukville 10:00', short_name:"PP-SV-10:00-6", vendor: vet_airbus) }
  describe '#create_vendor_stop' do
    context "Trip isn't existed" do
      it "should create vendor stop with trip's origin and destination for vet_airbus" do
        SpreeCmCommissioner::Trip.create(origin_id: phnom_penh.id, destination_id: siem_reap.id, departure_time: '10:00', duration: 3600, vehicle_id: bus1.id, product_id: vet_phnom_penh_siem_reap.id)
        vendor = vet_airbus
        expect(vendor.boarding_points.count).to eq(1)
        expect(vendor.drop_off_points.count).to eq(1)
        expect(vendor.boarding_points.first.name).to eq 'Phnom Penh'
        expect(vendor.drop_off_points.first.name).to eq 'Siem Reap'
        expect(larryta.boarding_points.count).to eq(0)
        expect(larryta.drop_off_points.count).to eq(0)
      end
      it "should not create duplicate vendor stop for PhnomPenh for vet_airbus" do
        SpreeCmCommissioner::Trip.create(origin_id: phnom_penh.id, destination_id: siem_reap.id, departure_time: '10:00', duration: 3600, vehicle_id: bus1.id, product_id: vet_phnom_penh_siem_reap.id)
        SpreeCmCommissioner::Trip.create(origin_id: phnom_penh.id, destination_id: sihanoukville.id, departure_time: '10:00', duration: 3600, vehicle_id: bus1.id, product_id: vet_phnom_penh_siem_reap.id)
        vendor = vet_airbus
        expect(vendor.boarding_points.count).to eq(1)
        expect(vendor.drop_off_points.count).to eq(2)
        expect(vendor.boarding_points).to contain_exactly(phnom_penh)
        expect(vendor.drop_off_points).to contain_exactly(siem_reap, sihanoukville)
        expect(larryta.boarding_points.count).to eq(0)
        expect(larryta.drop_off_points.count).to eq(0)
      end
    end
    context "add more stops on existing trip" do
      before do
        trip = SpreeCmCommissioner::Trip.create(origin_id: phnom_penh.id, destination_id: siem_reap.id, departure_time: '10:00', duration: 3600, vehicle_id: bus1.id, product_id: vet_phnom_penh_siem_reap.id)
        SpreeCmCommissioner::TripStop.create(trip_id: trip.id, stop_id: aeon1.id, stop_type: 'boarding')
        SpreeCmCommissioner::TripStop.create(trip_id: trip.id, stop_id: angkor_wat.id, stop_type: 'drop_off')
      end
      it "should create vendor stop with the new added stops for vet_airbus" do
        vendor = vet_airbus
        expect(vendor.boarding_points.count).to eq(2)
        expect(vendor.drop_off_points.count).to eq(2)
        expect(vendor.boarding_points).to contain_exactly(phnom_penh, aeon1)
        expect(vendor.drop_off_points).to contain_exactly(siem_reap, angkor_wat)
        expect(larryta.boarding_points.count).to eq(0)
        expect(larryta.drop_off_points.count).to eq(0)
      end
      it "should not create duplicate vendor stop for aeon1 for vet_airbus" do
        trip2 = SpreeCmCommissioner::Trip.create(origin_id: phnom_penh.id, destination_id: sihanoukville.id, departure_time: '10:00', duration: 3600, vehicle_id: bus1.id, product_id: vet_phnom_penh_siem_reap.id)
        SpreeCmCommissioner::TripStop.create(trip_id: trip2.id, stop_id: aeon1.id, stop_type: 'boarding')
        vendor = vet_airbus
        expect(vendor.boarding_points.count).to eq(2)
        expect(vendor.drop_off_points.count).to eq(3)
        expect(vendor.boarding_points).to contain_exactly(phnom_penh, aeon1)
        expect(vendor.drop_off_points).to contain_exactly(siem_reap, angkor_wat, sihanoukville)
        expect(larryta.boarding_points.count).to eq(0)
        expect(larryta.drop_off_points.count).to eq(0)
      end
    end
  end
end
