require 'spec_helper'

RSpec.describe SpreeCmCommissioner::VendorSearch do
  let(:phnom_penh) { create(:state, name: 'Phnom Penh') }
  let(:siem_reap) { create(:state, name: 'Siem Reap') }
  let(:params) { {name: 'White Mansion', province_id: phnom_penh.id } }
  let(:passenger_options) { SpreeCmCommissioner::PassengerOption.new(adult: 2, children: 1, room_qty: 1) }

  context '.call' do
    let!(:phnom_penh_hotel) { create(:cm_vendor_with_product, name: 'Phnom Penh Hotel', state_id: phnom_penh.id, permanent_stock: 10) }
    let!(:sokha_pp_hotel) { create(:cm_vendor_with_product, name: 'Sokha Phnom Penh Hotel', state_id: phnom_penh.id, permanent_stock: 20) }
    let!(:angkor_hotel) { create(:cm_vendor_with_product, name: 'Angkor Hotel', state_id: siem_reap.id, permanent_stock: 15) }

    context "when no booking" do
      let(:search_pp) { described_class.call(params: {from_date: '2022-12-29', to_date: '2022-12-30', province_id: phnom_penh.id}, passenger_options: passenger_options) }
      let(:search_sr) { described_class.call(params: {province_id: siem_reap.id}, passenger_options: passenger_options) }

      it 'return vendors in Siem Reap only' do
        expect(search_sr.vendors).to eq([angkor_hotel])
      end

      it 'return vendors in Phnom Penh only' do
        vendors = search_pp.vendors

        vendor_names = vendors.map(&:name)
        available_room_amount = vendors.map(&:total_inventory).sum

        expect(vendors.size).to eq 2
        expect(vendor_names).to include(phnom_penh_hotel.name)
        expect(vendor_names).to include(sokha_pp_hotel.name)
      end

      it 'return vendors with available room' do
        vendors = search_pp.vendors
        expect(vendors.first.total_booking).to eq 0
        expect(vendors.last.total_booking).to  eq 0

        expect(vendors.first.remaining).to eq vendors.first.total_inventory
        expect(vendors.last.remaining).to  eq vendors.last.total_inventory
      end
    end

    context "when booking" do

      let(:order1) { create(:order) } # match
      let(:order2) { create(:order) } # match
      let(:order3) { create(:order) } # unmatched

      let!(:make_order) {
        phnom_penh_hotel_room = phnom_penh_hotel.variants.first
        sokha_pp_hotel_room = sokha_pp_hotel.variants.first
        angkor_hotel_room = angkor_hotel.variants.first

        # book 3 rooms in both phnom_penh hotels
        order1.line_items.create(variant_id: phnom_penh_hotel_room.id, price: 100, quantity: 2, from_date: '2022-12-25', to_date: '2023-01-05', vendor_id: phnom_penh_hotel.id) #=> Phnom Penh Hotel remaining:  10 - 3 = 8
        order1.line_items.create(variant_id: sokha_pp_hotel_room.id, price: 100, quantity: 5, from_date: '2022-12-25', to_date: '2023-01-05', vendor_id: sokha_pp_hotel.id) #=> Sokha remaining:  20 - 5 = 15
        order1.line_items.create(variant_id: angkor_hotel_room.id, price: 100, quantity: 5, from_date: '2022-12-25', to_date: '2023-01-05', vendor_id: angkor_hotel.id) #=> Siem reap remaining:  15 - 5 = 10

        order2.line_items.create(variant_id: phnom_penh_hotel_room.id, price: 100, quantity: 5, from_date: '2022-12-29', to_date: '2022-12-31', vendor_id: phnom_penh_hotel.id) #=> Phnom Penh Hotel remaining: 8 - 5 = 3
        order3.line_items.create(variant_id: phnom_penh_hotel_room.id, price: 100, quantity: 10, from_date: '2023-01-01', to_date: '2023-01-31', vendor_id: phnom_penh_hotel.id) # unmatched
      }

      it 'search in Siem Reap' do
        search = described_class.call(params: {from_date: '2022-12-29', to_date: '2022-12-30', province_id: siem_reap.id}, passenger_options: passenger_options)
        vendor = search.vendors.first
        expect(vendor.name).to eq angkor_hotel.name
        expect(vendor.remaining).to eq 10
        expect(vendor.total_booking).to eq 5
      end

      it 'search in Phnom Penh' do
        search = described_class.call(params: {from_date: '2022-12-29', to_date: '2022-12-30', province_id: phnom_penh.id}, passenger_options: passenger_options)
        vendors = search.vendors
        expect(vendors.count).to eq 2

        pp_hotel = vendors.find { |v| v.name == phnom_penh_hotel.name }
        expect(pp_hotel.remaining).to eq 3
        expect(pp_hotel.total_booking).to eq 7

        sokha_hotel = vendors.find { |v| v.name == sokha_pp_hotel.name }
        expect(sokha_hotel.remaining).to eq 15
        expect(sokha_hotel.total_booking).to eq 5
      end
    end
  end
end
