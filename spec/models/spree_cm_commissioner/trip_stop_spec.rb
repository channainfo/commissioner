require 'spec_helper'

RSpec.describe SpreeCmCommissioner::TripStop, type: :model do
  let!(:vet_airbus) { create(:vendor, name: 'Vet Airbus', code: "VET") }
  let!(:larryta) { create(:vendor, name: 'Larryta', code: 'LTA') }

  # Locations
  let!(:phnom_penh) { create(:cm_place, name: 'Phnom Penh') }
  let!(:siem_reap) { create(:cm_place, name: 'Siem Reap') }
  let!(:sihanoukville) { create(:cm_place, name: 'Sihanoukville') }
  let!(:aeon1) { create(:cm_place, name: 'Aeon Mall 1') }
  let!(:angkor_wat) { create(:cm_place, name: 'Angkor Wat') }

  # Vehicle
  let!(:airbus) do
    create(:vehicle_type,
    :with_seats,
    code: "AIRBUS",
    vendor: vet_airbus,
    row: 4,
    column: 4)
  end
  let!(:bus1) { create(:vehicle, vehicle_type: airbus, vendor: vet_airbus) }

  # Option_Types
  let!(:origin_option_type) { create(:cm_option_type, :origin) }
  let!(:destination_option_type) { create(:cm_option_type, :destination) }
  let!(:duration_in_hours_option_type) { create(:cm_option_type, :duration_in_hours) }
  let!(:duration_in_minutes_option_type) { create(:cm_option_type, :duration_in_minutes) }
  let!(:departure_time_option_type) { create(:cm_option_type, :departure_time) }
  let!(:vehicle_option_type) { create(:cm_option_type, :vehicle) }
  let!(:allow_seat_selection_option_type) { create(:cm_option_type, :allow_seat_selection) }

  # Option_Values
  let!(:phnom_penh_option_value) { create(:cm_option_value, presentation: phnom_penh.name, name: phnom_penh.id, option_type: origin_option_type) }
  let!(:siem_reap_option_value) { create(:cm_option_value, presentation: siem_reap.name, name: siem_reap.id, option_type: destination_option_type) }
  let!(:sihanoukville_option_value) { create(:cm_option_value, presentation: sihanoukville.name, name: sihanoukville.id, option_type: destination_option_type) }
  let!(:aeon1_option_value) { create(:cm_option_value, presentation: aeon1.name, name: aeon1.id, option_type: origin_option_type) }
  let!(:angkor_wat_option_value) { create(:cm_option_value, presentation: angkor_wat.name, name: angkor_wat.id, option_type: origin_option_type) }
  let!(:departure_time_option_value) { create(:cm_option_value, presentation: '10:00', name: '10:00', option_type: departure_time_option_type) }
  let!(:duration_in_hours_option_value) { create(:cm_option_value, presentation: '5', name: '5', option_type: duration_in_hours_option_type) }
  let!(:vehicle_option_value) { create(:cm_option_value, presentation: bus1.code, name: bus1.id, option_type: vehicle_option_type) }

  # Routes
  let!(:vet_phnom_penh_siem_reap) { create(:route, name: 'VET Airbus Phnom Penh Siem Reap 10:00', short_name: "PP-SR-10:00-6", vendor: vet_airbus) }
  let!(:vet_phnom_penh_sihanoukville) { create(:route, name: 'VET Airbus Phnom Penh Sihanoukville 10:00', short_name: "PP-SV-10:00-6", vendor: vet_airbus) }

  before do
    vet_phnom_penh_siem_reap.option_types = [origin_option_type, destination_option_type, departure_time_option_type, duration_in_hours_option_type, vehicle_option_type]
    vet_phnom_penh_sihanoukville.option_types = [origin_option_type, destination_option_type, departure_time_option_type, duration_in_hours_option_type, vehicle_option_type]
  end

  describe '#create_vendor_stop' do
    context "Trip isn't existed" do
      it "should create vendor stop with trip's origin and destination for vet_airbus" do
        trip = Spree::Variant.create!(
          product_id: vet_phnom_penh_siem_reap.id,
          option_values: [phnom_penh_option_value, siem_reap_option_value, departure_time_option_value,
                          vehicle_option_value, duration_in_hours_option_value]
        )
        trip.save!
        vendor = vet_airbus
        expect(vendor.boarding_points.count).to eq(1)
        expect(vendor.drop_off_points.count).to eq(1)
        expect(vendor.boarding_points.first.name).to eq 'Phnom Penh'
        expect(vendor.drop_off_points.first.name).to eq 'Siem Reap'
        expect(larryta.boarding_points.count).to eq(0)
        expect(larryta.drop_off_points.count).to eq(0)
      end
      it "should not create duplicate vendor stop for PhnomPenh for vet_airbus" do
        Spree::Variant.create!(
          product_id: vet_phnom_penh_siem_reap.id,
          option_values: [phnom_penh_option_value, siem_reap_option_value, departure_time_option_value,
                          vehicle_option_value,duration_in_hours_option_value]
        )
        Spree::Variant.create!(
          product_id: vet_phnom_penh_siem_reap.id,
          option_values: [phnom_penh_option_value, sihanoukville_option_value, departure_time_option_value,
                          vehicle_option_value, duration_in_hours_option_value]
        )
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
        trip = Spree::Variant.create!(
          product_id: vet_phnom_penh_siem_reap.id,
          option_values: [phnom_penh_option_value, siem_reap_option_value, departure_time_option_value,
                          vehicle_option_value, duration_in_hours_option_value]
          )
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
        trip2 = Spree::Variant.create!(
          product_id: vet_phnom_penh_siem_reap.id,
          option_values: [phnom_penh_option_value, sihanoukville_option_value, departure_time_option_value,
                          vehicle_option_value, duration_in_hours_option_value]
          )
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
