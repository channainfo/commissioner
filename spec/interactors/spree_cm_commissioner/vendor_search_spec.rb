require 'spec_helper'

RSpec.describe SpreeCmCommissioner::VendorSearch do
  let(:phnom_penh) { create(:state, name: 'Phnom Penh') }
  let(:siem_reap) { create(:state, name: 'Siem Reap') }
  let!(:phnom_penh_hotel) { create(:cm_vendor_with_product, name: 'Phnom Penh Hotel', state_id: phnom_penh.id, permanent_stock: 10) }
  let!(:sokha_pp_hotel) { create(:cm_vendor_with_product, name: 'Sokha Phnom Penh Hotel', state_id: phnom_penh.id, permanent_stock: 20) }
  let!(:angkor_hotel) { create(:cm_vendor_with_product, name: 'Angkor Hotel', state_id: siem_reap.id, permanent_stock: 15) }
  let(:passenger_options) { SpreeCmCommissioner::PassengerOption.new(adult: 2, children: 1, room_qty: 1) }

  context '.call' do
    context "when no booking" do
      let(:search_pp) { described_class.call(params: { from_date: date('2022-12-29'), to_date: date('2022-12-30'), province_id: phnom_penh.id }, passenger_options: passenger_options) }
      let(:search_sr) { described_class.call(params: { from_date: date('2022-12-29'), to_date: date('2022-12-30'), province_id: siem_reap.id }, passenger_options: passenger_options) }

      it 'return vendors in Siem Reap only' do
        expect(search_sr.vendors).to eq([angkor_hotel])
      end

      it 'return vendors in Phnom Penh only' do
        vendors = search_pp.vendors

        vendor_names = vendors.map(&:name)

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
      let!(:line_item1) { book_room(create(:order), hotel: phnom_penh_hotel, quantity: 2,  from_date: date('2023_01_01'), to_date: date('2023_01_03')) }
      let!(:line_item2) { book_room(create(:order), hotel: phnom_penh_hotel, quantity: 3,  from_date: date('2023_01_01'), to_date: date('2023_01_09')) }
      let!(:line_item3) { book_room(create(:order), hotel: phnom_penh_hotel, quantity: 5,  from_date: date('2023_01_03'), to_date: date('2023_01_07')) }

      let!(:line_item4) { book_room(create(:order), hotel: sokha_pp_hotel,   quantity: 3,  from_date: date('2023_01_01'), to_date: date('2023_01_08')) }
      let!(:line_item5) { book_room(create(:order), hotel: sokha_pp_hotel,   quantity: 7,  from_date: date('2023_01_07'), to_date: date('2023_01_10')) }
      let!(:line_item6) { book_room(create(:order), hotel: sokha_pp_hotel,   quantity: 9,  from_date: date('2023_01_15'), to_date: date('2023_01_20')) }

      let!(:line_item7) { book_room(create(:order), hotel: angkor_hotel,   quantity: 1,  from_date: date('2023_01_01'), to_date: date('2023_01_02')) }
      let!(:line_item8) { book_room(create(:order), hotel: angkor_hotel,   quantity: 4,  from_date: date('2023_01_07'), to_date: date('2023_01_10')) }
      let!(:line_item9) { book_room(create(:order), hotel: angkor_hotel,   quantity: 5,  from_date: date('2023_01_15'), to_date: date('2023_01_20')) }

      it 'search in Siem Reap' do
        search = described_class.call(params: { from_date: date('2023_01_01'), to_date: date('2023_01_08'), province_id: siem_reap.id }, passenger_options: passenger_options)

        vendor = search.vendors.first
        expect(vendor.name).to eq angkor_hotel.name
        expect(vendor.remaining).to eq 11
        expect(vendor.total_booking).to eq 4
      end

      it 'search in Phnom Penh' do
        search = described_class.call(params: { from_date: date('2023_01_01'), to_date: date('2023_01_08'), province_id: phnom_penh.id }, passenger_options: passenger_options)
        vendors = search.vendors

        expect(vendors.size).to eq 2

        pp_hotel = vendors.find { |v| v.name == phnom_penh_hotel.name }
        expect(pp_hotel.remaining).to eq 0
        expect(pp_hotel.total_booking).to eq 10

        sokha_hotel = vendors.find { |v| v.name == sokha_pp_hotel.name }
        expect(sokha_hotel.remaining).to eq 10
        expect(sokha_hotel.total_booking).to eq 10
      end
    end
  end

  private

  def book_room(order, hotel: , price: 100, quantity: , from_date:, to_date:)
    room = hotel.variants.first # vip, air
    order.line_items.create(vendor_id: hotel.id, price: price, quantity: quantity, from_date: from_date, to_date: to_date, variant_id: room.id)
  end
end
