require 'spec_helper'

describe 'API V2 Storefront Accommodation Spec', type: :request do

  let(:phnom_penh) { create(:state, name: 'Phnom Penh') }
  let(:siem_reap)  { create(:state, name: 'Siem Reap') }
  let!(:phnom_penh_hotel) { create(:cm_vendor_with_product, name: 'Phnom Penh Hotel',       state_id: phnom_penh.id, permanent_stock: 10) }
  let!(:sokha_pp_hotel)   { create(:cm_vendor_with_product, name: 'Sokha Phnom Penh Hotel', state_id: phnom_penh.id, permanent_stock: 20) }
  let!(:angkor_hotel)     { create(:cm_vendor_with_product, name: 'Angkor Hotel',           state_id: siem_reap.id,  permanent_stock: 15) }
  let(:params) {
    { from_date: date('2023-01-01'), to_date: date('2023-01-03'), province_id: phnom_penh.id, adult: 2, children: 1, room_qty: 1 }
  }
  let(:json_response) { JSON.parse(response.body) }

  describe 'accommodation#index' do
    context 'when all hotels are available' do
      before { get '/api/v2/storefront/accommodations', params: params }

      it_behaves_like 'returns 200 HTTP status'
      it 'returns all phnom penh hotels' do
        expect(json_response["meta"]["count"]).to eq 2
      end

      it 'return total available of phnom penh hotel' do
        data = json_response['data'].find {|h| h['id'].to_i == phnom_penh_hotel.id }
        expect(data['attributes']['total_booking']).to eq 0
        expect(data['attributes']['remaining']).to eq phnom_penh_hotel.total_inventory
      end

      it 'return total available of phnom penh hotel' do
        data = json_response['data'].find {|h| h['id'].to_i == sokha_pp_hotel.id }
        expect(data['attributes']['total_booking']).to eq 0
        expect(data['attributes']['remaining']).to eq sokha_pp_hotel.total_inventory
      end
    end

    context "when match with booking dates" do
      let(:order) { create(:order) }
      let!(:pp_hotel_order) {
        book_room(order, hotel: phnom_penh_hotel, quantity: 2,  from_date: date('2023_01_01'), to_date: date('2023_01_02'))
      }
      let!(:sokha_pp_hotel_order) {
        book_room(order, hotel: sokha_pp_hotel,   quantity: 5,  from_date: date('2023_01_01'), to_date: date('2023_01_02'))
      }

      before { get '/api/v2/storefront/accommodations', params: params }

      it 'return total available of phnom penh hotel' do
        data = json_response['data'].find {|h| h['id'].to_i == phnom_penh_hotel.id }
        expect(data['attributes']['total_booking']).to eq pp_hotel_order.quantity
        expect(data['attributes']['remaining']).to eq (phnom_penh_hotel.total_inventory - pp_hotel_order.quantity)
      end

      it 'return total available of sokha phnom penh hotel' do
        data = json_response['data'].find {|h| h['id'].to_i == sokha_pp_hotel.id }
        expect(data['attributes']['total_booking']).to eq sokha_pp_hotel_order.quantity
        expect(data['attributes']['remaining']).to eq (sokha_pp_hotel.total_inventory - sokha_pp_hotel_order.quantity)
      end
    end

    context "when doesn't match with booking dates" do
      let(:order) { create(:order) }
      let!(:pp_hotel_order) {
        book_room(order, hotel: phnom_penh_hotel, quantity: 2,  from_date: date('2023_02_01'), to_date: date('2023_02_02'))
      }
      let!(:sokha_pp_hotel_order) {
        book_room(order, hotel: sokha_pp_hotel,   quantity: 5,  from_date: date('2023_02_01'), to_date: date('2023_02_02'))
      }

      before { get '/api/v2/storefront/accommodations', params: params }

      it 'return total available of phnom penh hotel' do
        data = json_response['data'].find {|h| h['id'].to_i == phnom_penh_hotel.id }
        expect(data['attributes']['total_booking']).to eq 0
        expect(data['attributes']['remaining']).to eq phnom_penh_hotel.total_inventory
      end

      it 'return total available of sokha phnom penh hotel' do
        data = json_response['data'].find {|h| h['id'].to_i == sokha_pp_hotel.id }
        expect(data['attributes']['total_booking']).to eq 0
        expect(data['attributes']['remaining']).to eq sokha_pp_hotel.total_inventory
      end
    end
  end

  describe 'accommodation#show' do
    let!(:vendor) { create(:cm_vendor_with_product, permanent_stock: 10, with_logo: true) }

    context "cannot find by id" do
      before { get "/api/v2/storefront/accommodations/#{vendor.id}", params: { include: 'logo,variants', from_date: '2023-01-01', to_date: '2023-01-02'} }

      it_behaves_like 'returns 422 HTTP status'

      it 'should return json with error' do
        expect(json_response['error']).to eq 'The accommodation you were looking for could not be found.'
      end
    end

    context "when the vendor's is all available" do
      before { get "/api/v2/storefront/accommodations/#{vendor.slug}", params: { include: 'logo,variants', from_date: '2023-01-01', to_date: '2023-01-02'} }

      it_behaves_like 'returns 200 HTTP status'

      it 'should return json with stock information' do
        expect(json_response['data']['attributes']['total_booking']).to eq 0
        expect(json_response['data']['attributes']['remaining']).to eq vendor.total_inventory
      end
    end

    context "when match with booking dates" do
      let!(:booking) {
        order = create(:order)
        book_room(order, hotel: vendor, quantity: 2,  from_date: date('2023_01_01'), to_date: date('2023_01_02'))
      }

      before { get "/api/v2/storefront/accommodations/#{vendor.slug}", params: { include: 'logo,variants', from_date: '2023-01-01', to_date: '2023-01-02'} }

      it_behaves_like 'returns 200 HTTP status'

      it 'should return json with stock information' do
        expect(json_response['data']['attributes']['total_booking']).to eq booking.quantity
        expect(json_response['data']['attributes']['remaining']).to eq (vendor.total_inventory - booking.quantity)
      end
    end
  end

  private

  def book_room(order, hotel: , price: 100, quantity: , from_date:, to_date:)
    room = hotel.variants.first
    order.line_items.create(vendor_id: hotel.id, price: price, quantity: quantity, from_date: from_date, to_date: to_date, variant_id: room.id)
  end
end
