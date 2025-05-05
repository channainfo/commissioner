require 'spec_helper'

RSpec.describe SpreeCmCommissioner::VendorStopPlaceQuery do
  let!(:cambodia)           { create(:cm_place, name: 'Cambodia', types: 'stop,branch') }
  let!(:phnom_penh)         { create(:cm_place, parent: cambodia, name: 'Phnom Penh', types: 'stop,branch') }

  let!(:khan_tuol_kork)     { create(:cm_place, parent: phnom_penh, name: 'Khan Toul Kork', types: 'stop,branch') }
  let!(:phsar_deum_kor)     { create(:cm_place, parent: phnom_penh, name: 'Phsar Deum Kor', types: 'stop,branch') }

  let!(:chamkar_mon)        { create(:cm_place, parent: phnom_penh, name: 'Chamkar Mon', types: 'stop,branch') }
  let!(:tuol_tompoung)      { create(:cm_place, parent: chamkar_mon, name: 'Tuol Tompoung', types: 'stop,branch') }
  let!(:phsar_tuol_tompoung){ create(:cm_place, parent: tuol_tompoung, name: 'Phsar Tuol Tompoung', types: 'stop,branch') }

  let!(:phsar_kandal)       { create(:cm_place, parent: phnom_penh, name: 'Phsar Kandal', types: 'stop,branch') }

  let!(:siem_reap)          { create(:cm_place, parent: cambodia, name: 'Siem Reap', types: 'stop,branch') }
  let!(:angkor_wat)         { create(:cm_place, parent: siem_reap, name: 'Angkor Wat', types: 'stop,branch') }

  let!(:banteay_meanchey)   { create(:cm_place, parent: cambodia, name: 'Banteay Meanchey', types: 'stop,branch') }
  let!(:mongkol_borey)      { create(:cm_place, parent: banteay_meanchey, name: 'Mongkol Borey', types: 'stop,branch') }
  let!(:poipet)             { create(:cm_place, parent: banteay_meanchey, name: 'Poipet', types: 'stop,branch') }
  let!(:sisophon)           { create(:cm_place, parent: banteay_meanchey, name: 'Sisophon', types: 'stop,branch') }

  # Vendor Setup
  let!(:vet_airbus) { create(:vendor, name: 'Vet Airbus', code: 'VET') }
  let!(:larryta)    { create(:vendor, name: 'Larryta', code: 'LRT') }

  # Vehicle Type Setup
  let!(:airbus) { create(:vehicle_type, :with_seats, code: "AIRBUS", vendor: vet_airbus, row: 4, column: 4) }
  let!(:bus1)   { create(:vehicle, vehicle_type: airbus, vendor: larryta) }
  let!(:bus2)   { create(:vehicle, vehicle_type: airbus, vendor: larryta) }

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
  let!(:phnom_penh_destination_option_value)  { create(:cm_option_value, presentation: phnom_penh.name, name: phnom_penh.id, option_type: destination_option_type) }
  let!(:banteay_meanchey_destination_option_value)   { create(:cm_option_value, presentation: banteay_meanchey.name, name: banteay_meanchey.id, option_type: destination_option_type) }
  let!(:poipet_destination_option_value){ create(:cm_option_value, presentation: poipet.name, name: poipet.id, option_type: destination_option_type) }
  let!(:bus1_option_value)              { create(:cm_option_value, presentation: bus1.code, name: bus1.id, option_type: vehicle_option_type) }
  let!(:bus2_option_value)              { create(:cm_option_value, presentation: bus2.code, name: bus2.id, option_type: vehicle_option_type) }

  # Option Values for travel times and durations
  let!(:departure_time_option_value1) { create(:cm_option_value, presentation: '5:00 AM', name: '5:00',  option_type: departure_time_option_type) }
  let!(:duration_h_option_value1)     { create(:cm_option_value, presentation: '5',       name: '5',     option_type: duration_h_option_type) }
  let!(:duration_mn_option_value1)    { create(:cm_option_value, presentation: '30',      name: '30',    option_type: duration_mn_option_type) }

  let!(:larryta_siem_reap_phnom_penh)      { create(:route, name: 'Larryta SR->PP 5:00',   short_name: 'SR-PP-5:00-6',  vendor: larryta) }
  let!(:vet_phnom_penh_banteay_meanchey)   { create(:route, name: 'VET-Air PP->BTM 5:00',  short_name: 'PP-BTM-5:00-6', vendor: vet_airbus) }
  let!(:larryta_phnom_penh_poipet)         { create(:route, name: 'VET-Air PP->BTM 5:00',  short_name: 'PP-BTM-5:00-6', vendor: larryta) }

  describe '.call' do
    let!(:trip1) do larryta_siem_reap_phnom_penh.variants.create!(
                                  option_values: [
                                    siem_reap_option_value,
                                    phnom_penh_destination_option_value,
                                    departure_time_option_value1,
                                    duration_h_option_value1,
                                    duration_mn_option_value1,
                                    bus1_option_value
                                  ],
                                  trip_stops_attributes: [
                                    { stop_id: angkor_wat.id, stop_type: "boarding" },
                                    { stop_id: phnom_penh.id, stop_type: "drop_off" },
                                    { stop_id: phsar_deum_kor.id, stop_type: "drop_off" },
                                    { stop_id: khan_tuol_kork.id, stop_type: "drop_off" },
                                    { stop_id: phsar_tuol_tompoung.id, stop_type: "drop_off" }
                                  ]
                                )
                              end
    let!(:trip2) do larryta_phnom_penh_poipet.variants.create!(
                                  option_values: [
                                    phnom_penh_origin_option_value,
                                    banteay_meanchey_destination_option_value,
                                    departure_time_option_value1,
                                    duration_h_option_value1,
                                    duration_mn_option_value1,
                                    bus2_option_value
                                  ],
                                  trip_stops_attributes: [
                                    { stop_id: khan_tuol_kork.id, stop_type: "boarding" },
                                    { stop_id: phsar_tuol_tompoung.id, stop_type: "boarding" },
                                    { stop_id: banteay_meanchey.id, stop_type: "drop_off" },
                                    { stop_id: mongkol_borey.id, stop_type: "drop_off" },
                                    { stop_id: poipet.id, stop_type: "drop_off" }
                                  ])
                                end
    let!(:trip3) do vet_phnom_penh_banteay_meanchey.variants.create!(option_values: [
                                    phnom_penh_origin_option_value,
                                    poipet_destination_option_value,
                                    departure_time_option_value1,
                                    duration_h_option_value1,
                                    duration_mn_option_value1,
                                    bus2_option_value
                                  ],
                                  trip_stops_attributes: [
                                    { stop_id: khan_tuol_kork.id, stop_type: "boarding" },
                                    { stop_id: phsar_deum_kor.id, stop_type: "boarding" },
                                    { stop_id: sisophon.id, stop_type: "drop_off" },
                                  ])
                                end
    let!(:trip4) do vet_phnom_penh_banteay_meanchey.variants.create!(option_values: [
                                  phnom_penh_origin_option_value,
                                  banteay_meanchey_destination_option_value,
                                  departure_time_option_value1,
                                  duration_h_option_value1,
                                  duration_mn_option_value1,
                                  bus2_option_value
                                ])
                              end
    let!(:trip5) do vet_phnom_penh_banteay_meanchey.variants.create!(option_values: [
                                phnom_penh_origin_option_value,
                                banteay_meanchey_destination_option_value,
                                departure_time_option_value1,
                                duration_h_option_value1,
                                duration_mn_option_value1,
                                bus2_option_value
                              ],
                              trip_stops_attributes: [
                                { stop_id: phsar_tuol_tompoung.id, stop_type: "boarding" },
                              ])
                            end
    context 'with vendor stops' do
      it 'returns 7 stops for VET' do
        vendor_stops = SpreeCmCommissioner::VendorStop.where(vendor: vet_airbus)
        boarding_stops = vendor_stops.where(stop_type: :boarding)
        drop_off_stops = vendor_stops.where(stop_type: :drop_off)
        expect(vendor_stops.count).to eq(7)
        expect(boarding_stops.count).to eq(4)
        expect(drop_off_stops.count).to eq(3)
        expect(boarding_stops.sum(&:trip_count)).to eq(6)
        expect(drop_off_stops.sum(&:trip_count)).to eq(4)
      end
      it 'returns 5 boarding and 7 drop_off stops for Larryta' do
        vendor_stops = SpreeCmCommissioner::VendorStop.where(vendor: larryta)
        boarding_stops = vendor_stops.where(stop_type: :boarding)
        drop_off_stops = vendor_stops.where(stop_type: :drop_off)
        expect(boarding_stops.count).to eq(5)
        expect(drop_off_stops.count).to eq(7)
      end
    end
    context 'with Larryta as Vendor' do
      it 'returns full nested result name for "Tuol" match' do
        search_keyword = 'Tuol'
        larryta_boarding = described_class.new(query: search_keyword, vendor_id: larryta.id).call

        puts build_table("'#{search_keyword}' [Larryta]", larryta_boarding)

        expect(larryta_boarding.map { |r| r[:name] }).to include(
          'Phsar Tuol Tompoung, Tuol Tompoung, Chamkar Mon, Phnom Penh, Cambodia'
        )

      end
      it 'returns drop off stops for reference boarding Phnom Penh' do
        search_keyword = ''
        larryta_drop_offs = described_class.new(query: search_keyword,
                                                vendor_id: larryta.id,
                                                reference_stop_id: phnom_penh.id,
                                                stop_type: :drop_off).call
        puts build_table("'#{search_keyword}' [Larryta] drop_offs", larryta_drop_offs)
        expect(larryta_drop_offs.map { |r| r[:name] }).to include(
          'Phsar Tuol Tompoung, Tuol Tompoung, Chamkar Mon, Phnom Penh, Cambodia',
          'Poipet, Banteay Meanchey, Cambodia',
          'Banteay Meanchey, Cambodia',
          'Mongkol Borey, Banteay Meanchey, Cambodia',
          'Phsar Deum Kor, Phnom Penh, Cambodia',
          'Khan Toul Kork, Phnom Penh, Cambodia',
          'Phnom Penh, Cambodia'
        )
      end
    end

    context 'with VET as Vendor' do
      it 'returns multiple results for general query like "Ph"' do
        search_keyword = 'Ph'
        vet_results = described_class.new(query: search_keyword, vendor_id: vet_airbus.id).call
        puts build_table("'#{search_keyword}' [VET]", vet_results)

        expect(vet_results.map { |r| r[:name] }).to include(
          'Phnom Penh, Cambodia',
          'Phsar Tuol Tompoung, Tuol Tompoung, Chamkar Mon, Phnom Penh, Cambodia',
        )
      end

      it 'returns drop off stops for "" match' do
        search_keyword = ''
        vet_results = described_class.new(query: search_keyword,
                                          vendor_id: vet_airbus.id,
                                          reference_stop_id: phsar_deum_kor.id,
                                          stop_type: :drop_off).call
        puts build_table("'#{search_keyword}' [VET]", vet_results)

        expect(vet_results.map { |r| r[:name] }).to include(
          'Sisophon, Banteay Meanchey, Cambodia',
          'Poipet, Banteay Meanchey, Cambodia',
          'Banteay Meanchey, Cambodia'
        )
      end
    end

    it 'returns first 20 stops when no query is provided' do
      search_keyword = ''
      larryta_results = described_class.new(query: search_keyword, vendor_id: larryta.id).call
      vet_results = described_class.new(query: search_keyword, vendor_id: vet_airbus.id).call
      puts build_table("'#{search_keyword}' [Larryta]", larryta_results)
      puts build_table("'#{search_keyword}' [VET]", vet_results)

      expect(larryta_results.size).to eq(larryta.boarding_points.size || 20)
      expect(vet_results.size).to eq(vet_airbus.boarding_points.size  || 20)
    end

    it 'returns empty array when no match is found' do
      search_keyword = 'NoMatch'
      larryta_results = described_class.new(query: search_keyword, vendor_id: larryta.id).call
      vet_results = described_class.new(query: search_keyword, vendor_id: vet_airbus.id).call

      puts build_table("'#{search_keyword}' [Larryta]", larryta_results)
      puts build_table("'#{search_keyword}' [VET]", vet_results)

      expect(larryta_results).to be_empty
      expect(vet_results).to be_empty
    end
  end
end

def build_table(search_keyword, query_result)
  table = Terminal::Table.new headings: ['ID', "Result for #{search_keyword} "]
  query_result.each do |result|
    table.add_row([result[:id], result[:name]])
  end
  table
end
