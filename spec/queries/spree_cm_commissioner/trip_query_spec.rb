require 'spec_helper'
RSpec.describe SpreeCmCommissioner::TripQuery do
  # Vendor Setup
  let!(:vet_airbus) { create(:vendor, name: 'Vet Airbus', code: 'VET') }

  # Vehicle Type Setup
  let!(:airbus) { create(:vehicle_type, :with_seats, code: "AIRBUS", vendor: vet_airbus, row: 4, column: 4) }
  let!(:bus1)   { create(:vehicle, vehicle_type: airbus, vendor: vet_airbus) }
  let!(:bus2)   { create(:vehicle, vehicle_type: airbus, vendor: vet_airbus) }

  # Creating Places
  let!(:phnom_penh)   { create(:cm_place, name: 'Phnom Penh') }
  let!(:angkor)     { create(:cm_place, name: 'Angkor') }
  let!(:siem_reap)    { create(:cm_place, name: 'Siem Reap') }
  let!(:ho_chi_minh)  { create(:cm_place, name: 'Ho Chi Minh') }

  # Option Type Setup
  let!(:origin_option_type)         { create(:cm_option_type, :origin) }
  let!(:destination_option_type)    { create(:cm_option_type, :destination) }
  let!(:departure_time_option_type) { create(:cm_option_type, :departure_time) }
  let!(:duration_h_option_type)     { create(:cm_option_type, :duration_in_hours) }
  let!(:duration_mn_option_type)    { create(:cm_option_type, :duration_in_minutes) }
  let!(:vehicle_option_type)        { create(:cm_option_type, :vehicle) }

  # Option Values Setup
  let!(:phnom_penh_origin_option_value) { create(:cm_option_value, presentation: phnom_penh.name, name: phnom_penh.id, option_type: origin_option_type) }
  let!(:siem_reap_option_value)         { create(:cm_option_value, presentation: siem_reap.name, name: siem_reap.id, option_type: origin_option_type) }
  let!(:ho_chi_minh_option_value)       { create(:cm_option_value, presentation: ho_chi_minh.name, name: ho_chi_minh.id, option_type: destination_option_type) }
  let!(:phnom_penh_destination_option_value)  { create(:cm_option_value, presentation: phnom_penh.name, name: phnom_penh.id, option_type: destination_option_type) }
  let!(:siem_reap_destination_option_value)   { create(:cm_option_value, presentation: siem_reap.name, name: siem_reap.id, option_type: destination_option_type) }
  let!(:bus1_option_value)              { create(:cm_option_value, presentation: bus1.code, name: bus1.id, option_type: vehicle_option_type) }
  let!(:bus2_option_value)              { create(:cm_option_value, presentation: bus2.code, name: bus2.id, option_type: vehicle_option_type) }

  # Option Values for travel times and durations
  let!(:departure_time_option_value1) { create(:cm_option_value, presentation: '5:00 AM', name: '5:00',  option_type: departure_time_option_type) }
  let!(:duration_h_option_value1)     { create(:cm_option_value, presentation: '5',       name: '5',     option_type: duration_h_option_type) }
  let!(:duration_mn_option_value1)    { create(:cm_option_value, presentation: '30',      name: '30',    option_type: duration_mn_option_type) }
  let!(:departure_time_option_value2) { create(:cm_option_value, presentation: '1:00 PM', name: '13:00', option_type: departure_time_option_type) }
  let!(:duration_h_option_value2)     { create(:cm_option_value, presentation: '9',       name: '9',     option_type: duration_h_option_type) }

  # Creating Routes (Legs) for the trips
  let!(:vet_siem_reap_phnom_penh)   { create(:route, name: 'VET-Air SR->PP 5:00',   short_name: 'SR-PP-5:00-6',   vendor: vet_airbus) }
  let!(:vet_phnom_penh_ho_chi_minh) { create(:route, name: 'VET-Air PP->HCM 13:00', short_name: 'PP-HCM-13:00-6', vendor: vet_airbus) }
  let!(:vet_siem_reap_ho_chi_minh)  { create(:route, name: 'VET-Air SR->HCM 5:00',  short_name: 'SR-HCM-5:00-6',  vendor: vet_airbus) }

  # Test Setup
  let(:origin_id)       { siem_reap.id }
  let(:destination_id)  { ho_chi_minh.id }
  let(:travel_date)     { Date.tomorrow }

  let(:result)          { described_class.new(origin_id: origin_id, destination_id: destination_id, travel_date: travel_date) }

  describe '.call' do
    # Creating Trip Variants
    let!(:first_leg_variant) do vet_siem_reap_phnom_penh.variants.create!(
                                  option_values: [
                                    siem_reap_option_value,
                                    phnom_penh_destination_option_value,
                                    departure_time_option_value1,
                                    duration_h_option_value1,
                                    duration_mn_option_value1,
                                    bus1_option_value
                                  ]
                                )
                              end


    let!(:second_leg_variant) { vet_phnom_penh_ho_chi_minh.variants.create!(option_values: [
                                phnom_penh_origin_option_value,
                                ho_chi_minh_option_value,
                                departure_time_option_value2,
                                duration_h_option_value2,
                                bus2_option_value
                              ]) }

    context 'when direct trips are available' do
      let!(:direct_trip_variant) {  vet_siem_reap_ho_chi_minh.variants.create!(option_values: [
                                    siem_reap_option_value,
                                    ho_chi_minh_option_value,
                                    departure_time_option_value2,
                                    duration_h_option_value2,
                                    bus2_option_value,
                                  ]) }
      let(:direct_trips) { [direct_trip_variant] }
      let(:connected_trips) { [] }

      it 'returns the available direct trips with correct time and duration' do
        search_result = result.call
        table = construct_table(search_result)

        table.style = { alignment: :center }
        puts table

        trip = search_result.first.trips.first
        expect(search_result.count).to eq(direct_trips.count)
        expect(trip.origin_id).to eq(origin_id)
        expect(trip.destination_id).to eq(destination_id)
        expect(trip.departure_time.strftime('%H:%M:%S')).to be_between(
                travel_date.beginning_of_day.strftime('%H:%M:%S'),
                travel_date.end_of_day.strftime('%H:%M:%S')
              ).inclusive
      end
    end

    context 'when no direct trips are available' do
      let!(:connection)     { create(:trip_connection, from_trip: first_leg_variant, to_trip: second_leg_variant) }
      let(:direct_trips)    { [] }
      let!(:connected_trips) { [connection] }

      it 'returns the connected trips, matching the origin of the first leg and destination of the second leg' do
        search_result = result.call
        table = construct_table(search_result)

        table.style = { alignment: :center }
        puts table

        from_trip = search_result.first.trips.first
        to_trip = search_result.first.trips.last

        expect(search_result.count).to eq(connected_trips.count)
        expect(from_trip.origin_id).to eq(origin_id)
        expect(from_trip.destination_id).to eq(to_trip.origin_id)
        expect(to_trip.destination_id).to eq(destination_id)
      end
    end

    context 'when layover time, origin, and destination of both trips do not match the criteria' do
      let(:search_result) { result.call }

      it 'returns empty when the layover time is not within the expected range' do
        first_leg_variant.option_values = first_leg_variant.option_values.where.not(option_type: departure_time_option_type)
        first_leg_variant.option_values << departure_time_option_value2
        first_leg_variant.save!

        expect(search_result.count).to eq(0)
      end

      it 'returns empty when the origin and destination of the trips do not match' do
        first_leg_variant.option_values = first_leg_variant.option_values.where.not(option_type: [origin_option_type, destination_option_type])
        first_leg_variant.option_values << phnom_penh_origin_option_value
        first_leg_variant.option_values << siem_reap_destination_option_value
        first_leg_variant.save!

        expect(search_result.count).to eq(0)
      end
    end

    context 'when direct trips return less than 3 results' do
      let!(:direct_trip_variant) {  vet_siem_reap_ho_chi_minh.variants.create!(option_values: [
                                    siem_reap_option_value,
                                    ho_chi_minh_option_value,
                                    departure_time_option_value2,
                                    duration_h_option_value2,
                                    bus2_option_value
                                  ]) }
      let!(:connection)      { create(:trip_connection, from_trip: first_leg_variant, to_trip: second_leg_variant) }
      let!(:direct_trips)    { [direct_trip_variant] }
      let!(:connected_trips) { [connection] }

      it 'search for trip connections and include in search results' do
        first_leg_variant.option_values = first_leg_variant.option_values.where.not(option_type: departure_time_option_type)
        first_leg_variant.option_values << departure_time_option_value2
        first_leg_variant.save!

        search_result = result.call
        table = construct_table(search_result)
        table.style = { alignment: :center }
        puts table

        expect(search_result.count).to eq(direct_trips.count + connected_trips.count)
      end
    end

    context 'when given params filter the results' do
      let!(:direct_trip_variant) {  vet_siem_reap_ho_chi_minh.variants.create!(option_values: [
                                    siem_reap_option_value,
                                    ho_chi_minh_option_value,
                                    departure_time_option_value2,
                                    duration_h_option_value2,
                                    bus2_option_value
                                  ]) }
      let!(:direct_trips)    { [direct_trip_variant] }
      let!(:connection)      { create(:trip_connection, from_trip: first_leg_variant, to_trip: second_leg_variant) }
      let!(:connected_trips) { [connection] }
      let(:result1)          { described_class.new(origin_id: origin_id, destination_id: destination_id, travel_date: travel_date, params: {trip_type: 'direct'}) }
      let(:result2)          { described_class.new(origin_id: origin_id, destination_id: destination_id, travel_date: travel_date, params: {trip_type: 'connected'}) }
      it 'returns only direct or connected trips when trip_type is set filter' do
        search_result1 = result1.call
        trip = search_result1.first.trips.first
        expect(search_result1.count).to eq(1)
        expect(search_result1.first).to be_a(SpreeCmCommissioner::TripQueryResult)
        expect(trip.origin_id).to eq(origin_id)
        expect(trip.destination_id).to eq(destination_id)

        search_result2 = result2.call
        trip1 = search_result2.first.trips.first
        trip2 = search_result2.first.trips.last
        expect(search_result2.count).to eq(1)
        expect(search_result2.first).to be_a(SpreeCmCommissioner::TripQueryResult)
        expect(trip1.origin_id).to eq(origin_id)
        expect(trip2.destination_id).to eq(destination_id)

      end
    end
  end


  describe '.direct_trips' do
    it 'returns the direct trips from the database' do
      vet_siem_reap_ho_chi_minh.variants.create!(option_values: [siem_reap_option_value,
                                                                ho_chi_minh_option_value,
                                                                departure_time_option_value2,
                                                                duration_h_option_value2,
                                                                bus2_option_value
                                                                ])
      direct_trips = result.direct_trips
      expect(direct_trips).not_to be_empty
      expect(direct_trips.first).to be_a(SpreeCmCommissioner::TripResult)
      expect(direct_trips.first.origin_id).to eq(origin_id)
      expect(direct_trips.first.destination_id).to eq(destination_id)
    end
  end

  describe '.connected_trips' do
    let!(:first_leg_variant)  { vet_siem_reap_phnom_penh.variants.create!(option_values: [
                                siem_reap_option_value,
                                phnom_penh_destination_option_value,
                                departure_time_option_value1,
                                duration_h_option_value1,
                                duration_mn_option_value1,
                                bus1_option_value
                              ]) }

    let!(:second_leg_variant) { vet_phnom_penh_ho_chi_minh.variants.create!(option_values: [
                                phnom_penh_origin_option_value,
                                ho_chi_minh_option_value,
                                departure_time_option_value2,
                                duration_h_option_value2,
                                bus2_option_value
                              ]) }
    it 'returns the connected trips from the database' do
      create(:trip_connection, from_trip: first_leg_variant, to_trip: second_leg_variant)
      connected_trips = result.connected_trips
      expect(connected_trips).not_to be_empty
      expect(connected_trips.first).to be_a(SpreeCmCommissioner::TripQueryResult)
      expect(connected_trips.first.trips.first.origin_id).to eq(origin_id)
      expect(connected_trips.first.trips.last.destination_id).to eq(destination_id)
    end
  end
end

def construct_table(search_result)
  table = Terminal::Table.new :headings => ['Connected', 'Trip ID', 'Vendor', 'Short Name',
                                             'Origin', 'Destination', 'Departure Time', 'Arrival Time',
                                             'Duration', 'Vehicle', 'Description']

  search_result.each do |r|
    if r&.direct?
      trip = r.trips.first
      table.add_row [
        'Direct',
        trip.trip_id,
        trip.vendor_name,
        trip.short_name,
        "#{trip.origin || 'Unknown'} - #{trip.origin_id || 'N/A'}",
        "#{trip.destination || 'Unknown'} - #{trip.destination_id || 'N/A'}",
        trip.departure_time.strftime('%H:%M'),
        trip.arrival_time,
        trip.duration_in_hms,
        trip.vehicle_id,
        ''
      ]
    else
      from_trip = r.trips.first
      to_trip = r.trips.last
      table.add_row [
        "Connected (#{r.connection_id})",
        "#{from_trip.trip_id} → #{to_trip.trip_id}",
        "#{from_trip.vendor_name}\n#{to_trip.vendor_name}",
        "#{from_trip.short_name} →  #{to_trip.short_name}",
        "#{from_trip.origin || 'Unknown'} - #{from_trip.origin_id || 'N/A'}",
        "#{to_trip.destination || 'Unknown'} - #{to_trip.destination_id || 'N/A'}",
        "#{from_trip.departure_time.strftime('%H:%M')} \n#{to_trip.departure_time.strftime('%H:%M')}",
        "#{from_trip.arrival_time} \n#{to_trip.arrival_time}",
        "T1: #{from_trip.duration_in_hms}\n T2: #{to_trip.duration_in_hms}",
        "#{from_trip.vehicle_id} → #{to_trip.vehicle_id}",
        "Legs: #{from_trip.origin} → #{to_trip.origin} - #{to_trip.destination}\nLayover: #{from_trip.arrival_time} - #{to_trip.departure_time.strftime('%H:%M')}"
      ]
    end
    table.add_separator unless r.equal?(search_result.last) # Avoid adding separator after last row
  end
  table
end
