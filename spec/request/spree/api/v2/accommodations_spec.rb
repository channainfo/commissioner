require 'spec_helper'

describe 'API V2 Storefront Accommodation Spec', type: :request do
  let(:next_month) { Time.zone.now.next_month }
  let(:last_month) { Time.zone.now.last_month }

  let(:phnom_penh) { create(:state, name: 'Phnom Penh') }
  let(:siem_reap)  { create(:state, name: 'Siem Reap') }
  let!(:phnom_penh_hotel) { create(:cm_vendor_with_product, name: 'Phnom Penh Hotel',       default_state_id: phnom_penh.id, permanent_stock: 10) }
  let!(:sokha_pp_hotel)   { create(:cm_vendor_with_product, name: 'Sokha Phnom Penh Hotel', default_state_id: phnom_penh.id, permanent_stock: 20) }
  let!(:angkor_hotel)     { create(:cm_vendor_with_product, name: 'Angkor Hotel',           default_state_id: siem_reap.id,  permanent_stock: 15) }
  let(:params) {
    { from_date: next_month, to_date: next_month + 2.days, province_id: phnom_penh.id, adult: 2, children: 1, room_qty: 1 }
  }
  let(:monday) { next_month.beginning_of_week }
  let(:sunday) { next_month.end_of_week }

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
        book_room(order, hotel: phnom_penh_hotel, quantity: 2,  from_date: next_month, to_date: next_month + 1.days)
      }
      let!(:sokha_pp_hotel_order) {
        book_room(order, hotel: sokha_pp_hotel,   quantity: 5,  from_date: next_month, to_date: next_month + 1.days)
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
        book_room(order, hotel: phnom_penh_hotel, quantity: 2,  from_date: next_month.next_month, to_date: next_month.next_month + 1.days)
      }
      let!(:sokha_pp_hotel_order) {
        book_room(order, hotel: sokha_pp_hotel,   quantity: 5,  from_date: next_month.next_month, to_date: next_month.next_month + 1.days)
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

    context 'when no service_calendar' do
      before { get '/api/v2/storefront/accommodations', params: params }

      it 'should have service available for phnom penh hotel' do
        data = json_response['data'].find {|h| h['id'].to_i == phnom_penh_hotel.id }

        expect(data['attributes']['service_availabilities'].map {|a| a['date'] }).to eq [day_to_s(next_month), day_to_s(next_month+1.days), day_to_s(next_month+2.days)]
        expect(data['attributes']['service_availabilities'].map {|a| a['available'] }).to eq [true, true, true]
      end

      it 'should have service available for sokha_pp_hotel' do
        data = json_response['data'].find {|h| h['id'].to_i == sokha_pp_hotel.id }

        expect(data['attributes']['service_availabilities'].map {|a| a['date'] }).to eq [day_to_s(next_month), day_to_s(next_month+1.days), day_to_s(next_month+2.days)]
        expect(data['attributes']['service_availabilities'].map {|a| a['available'] }).to eq [true, true, true]
      end
    end

    context 'when service_calendar permanant close' do
      before { create(:cm_service_calendar_no_available, calendarable: phnom_penh_hotel) }
      before { get '/api/v2/storefront/accommodations', params: params }

      it 'phnom_penh_hotel is closed' do
        data = json_response['data'].find {|h| h['id'].to_i == phnom_penh_hotel.id }
        expect(data['attributes']['service_availabilities'].map {|a| a['date'] }).to eq [day_to_s(next_month), day_to_s(next_month+1.days), day_to_s(next_month+2.days)]
        expect(data['attributes']['service_availabilities'].map {|a| a['available'] }).to eq [false, false, false]
      end

      it 'sokha_pp_hotel is open as normal' do
        data = json_response['data'].find {|h| h['id'].to_i == sokha_pp_hotel.id }
        expect(data['attributes']['service_availabilities'].map {|a| a['date'] }).to eq [day_to_s(next_month), day_to_s(next_month+1.days), day_to_s(next_month+2.days)]
        expect(data['attributes']['service_availabilities'].map {|a| a['available'] }).to eq [true, true, true]
      end
    end

    context 'when service_calendar close on weekend' do
      before { create(:cm_service_calendar, saturday: false, sunday: false, calendarable: phnom_penh_hotel) }
      before { get '/api/v2/storefront/accommodations', params:  { from_date: monday, to_date: sunday, province_id: phnom_penh.id, adult: 2, children: 1, room_qty: 1 } }

      it 'phnom_penh_hotel should close on weekend' do
        data = json_response['data'].find {|h| h['id'].to_i == phnom_penh_hotel.id }

        expect(data['attributes']['service_availabilities'].map {|a| a['date'] }).to eq ((monday.to_date)..(sunday.to_date)).map(&:to_s)
        expect(data['attributes']['service_availabilities'].map {|a| a['available'] }).to eq [true, true, true, true, true, false, false]
      end
    end

    context 'when service_calendar overlap with close' do
      let!(:setup) {
        create(:cm_service_calendar, calendarable: phnom_penh_hotel) # available all
        create(:cm_service_calendar, monday: false, wednesday: false, start_date: monday, end_date: sunday, calendarable: phnom_penh_hotel)
      }
      before { get '/api/v2/storefront/accommodations', params:  { from_date: monday, to_date: sunday, province_id: phnom_penh.id, adult: 2, children: 1, room_qty: 1 } }

      it 'phnom_penh_hotel should close on monday & wednesday' do
        data = json_response['data'].find {|h| h['id'].to_i == phnom_penh_hotel.id }
        expect(data['attributes']['service_availabilities'].map {|a| a['date'] }).to eq ((monday.to_date)..(sunday.to_date)).map(&:to_s)
        expect(data['attributes']['service_availabilities'].map {|a| a['available'] }).to eq [false, true, false, true, true, true, true]
      end
    end

    context 'when service_calendar with exception_rules' do
      let(:params) { { from_date: monday, to_date: sunday, province_id: phnom_penh.id, adult: 2, children: 1, room_qty: 1 } }
      let(:response_data) { json_response['data'].find {|h| h['id'].to_i == phnom_penh_hotel.id } }

      it 'phnom_penh_hotel should open on Sunday' do
        create(:cm_service_calendar, sunday: false, calendarable: phnom_penh_hotel, exception_rules: [{ from: day_to_s(sunday), to: day_to_s(sunday), type: 'inclusion' }])
        get '/api/v2/storefront/accommodations', params: params

        service = response_data['attributes']['service_availabilities'].find { |s| s['date'] == day_to_s(sunday) }
        expect(service['available']).to eq true
      end

      it 'phnom_penh_hotel should close on Monday' do
        create(:cm_service_calendar, calendarable: phnom_penh_hotel, exception_rules: [{ from: day_to_s(monday), to: day_to_s(monday), type: 'exclusion' }])
        get '/api/v2/storefront/accommodations', params: params

        service = response_data['attributes']['service_availabilities'].find { |s| s['date'] == day_to_s(monday) }
        expect(service['available']).to eq false
      end
    end

    context 'validation error' do

      it 'when from_date > to_date' do
        get '/api/v2/storefront/accommodations', params: { from_date: monday, to_date: monday - 1, province_id: phnom_penh.id, adult: 2, children: 1, room_qty: 1 }

        expect(response.status).to eq 422
        expect(json_response['error']).to eq "End Date must be later than or equal Start Date"
      end

      it 'when from_date and to_date is too long' do
        get '/api/v2/storefront/accommodations', params: { from_date: monday, to_date: monday + (max_stay_days+1).days, province_id: phnom_penh.id, adult: 2, children: 1, room_qty: 1 }

        expect(response.status).to eq 422
        expect(json_response['error']).to eq "Stay duration is too long"
      end
    end
  end

  describe 'accommodation#show' do
    let!(:vendor) { create(:cm_vendor_with_product, permanent_stock: 10, with_logo: true) }

    context "when the vendor's is all available" do
      before { get "/api/v2/storefront/accommodations/#{vendor.slug}", params: { include: 'logo,variants', from_date: next_month, to_date: next_month + 1.days} }

      it_behaves_like 'returns 200 HTTP status'

      it 'should return json with stock information' do
        expect(json_response['data']['attributes']['total_booking']).to eq 0
        expect(json_response['data']['attributes']['remaining']).to eq vendor.total_inventory
      end

      it 'return service_availabilites of phnom penh hotel' do
        expect(json_response['data']['attributes']['service_availabilities'].map {|a| a['date'] }).to eq [day_to_s(next_month), day_to_s(next_month+1.days)]
        expect(json_response['data']['attributes']['service_availabilities'].map {|a| a['available'] }).to eq [true, true]
      end
    end

    context "when match with booking dates" do
      let!(:booking) {
        order = create(:order)
        book_room(order, hotel: vendor, quantity: 2,  from_date: next_month, to_date: next_month + 2.days)
      }

      before { get "/api/v2/storefront/accommodations/#{vendor.slug}", params: { include: 'logo,variants', from_date: next_month, to_date: next_month + 2.days} }

      it_behaves_like 'returns 200 HTTP status'

      it 'should return json with stock information' do
        expect(json_response['data']['attributes']['total_booking']).to eq booking.quantity
        expect(json_response['data']['attributes']['remaining']).to eq (vendor.total_inventory - booking.quantity)
      end
    end

    context 'validation error' do
      it 'when from_date is in the past' do
        get "/api/v2/storefront/accommodations/#{vendor.slug}", params: { from_date: last_month, to_date: last_month + 1.days }

        expect(response.status).to eq 422
        expect(json_response['error']).to eq "Start date must be today or in future"
      end

      it 'when from_date > to_date' do
        get "/api/v2/storefront/accommodations/#{vendor.slug}", params: { from_date: monday, to_date: monday - 1.days }

        expect(response.status).to eq 422
        expect(json_response['error']).to eq "End Date must be later than or equal Start Date"
      end

      it 'when from_date and to_date is too long' do
        get "/api/v2/storefront/accommodations/#{vendor.slug}", params: { from_date: next_month, to_date: next_month + (max_stay_days+1).days }

        expect(response.status).to eq 422
        expect(json_response['error']).to eq "Stay duration is too long"
      end
    end
  end

  private

  def book_room(order, hotel: , price: 100, quantity: , from_date:, to_date:)
    room = hotel.variants.first
    order.line_items.create(vendor_id: hotel.id, price: price, quantity: quantity, from_date: from_date, to_date: to_date, variant_id: room.id)
  end

  def day_to_s(day)
    day.strftime("%F")
  end

  def max_stay_days
    ENV.fetch('ACCOMMODATION_MAX_STAY_DAYS', 10).to_i
  end
end
