require 'spec_helper'

describe 'API V2 Storefront Vendor Spec', type: :request do
  let(:json_response) { JSON.parse(response.body) }

  describe 'vendors#show' do
    let!(:vendor_logo) { create(:vendor_logo) }
    let!(:vendor) { create(:active_vendor, name: 'vendor', logo: vendor_logo) }

    context 'with logo included' do
      before { get "/api/v2/storefront/vendors/#{vendor.slug}?include=logo" }

      it_behaves_like 'returns 200 HTTP status'

      it 'returns logo information' do
        expect(json_response.keys).to contain_exactly('data', 'included')

        expect(json_response['included'].first['id']).to eq(vendor_logo.id.to_s)
        expect(json_response['included'].first['attributes']['styles'].length).to eq(2)
      end
    end

    context 'with attribute min and max price' do
      before { get "/api/v2/storefront/vendors/#{vendor.slug}" }

      it_behaves_like 'returns 200 HTTP status'

      it 'returns min and max price attribute' do
        expect(json_response['data']['attributes']).to have_key('min_price')
        expect(json_response['data']['attributes']).to have_key('max_price')
      end
    end

    context 'with invalid slug' do
      it 'return 404 on resource not found' do
        get "/api/v2/storefront/vendors/not-found"

        expect(json_response['error'].present?).to eq true
        expect(response.status).to eq 404
      end

      it 'return 404 when vendor is blocked' do
        blocked_vendor = create(:vendor, state: 'blocked')
        get "/api/v2/storefront/vendors/#{blocked_vendor.slug}"

        expect(json_response['error'].present?).to eq true
        expect(response.status).to eq 404
      end

      it 'return 404 when vendor is pending' do
        pending_vendor = create(:vendor, state: 'pending')
        get "/api/v2/storefront/vendors/#{pending_vendor.slug}"

        expect(json_response['error'].present?).to eq true
        expect(response.status).to eq 404
      end
    end

    context 'with validated vendor slug' do
      it 'successfully response active vendor' do
        get "/api/v2/storefront/vendors/#{vendor.slug}"

        expect(response.status).to eq 200
        expect(json_response['data']['id']).to eq vendor.id.to_s

        expect(json_response['data']['attributes']['name']).to eq vendor.name
        expect(json_response['data']['attributes']['about_us']).to eq vendor.about_us
        expect(json_response['data']['attributes']['slug']).to eq vendor.slug
        expect(json_response['data']['attributes']['contact_us']).to eq vendor.contact_us

        expect(json_response['data']['relationships']['image'].present?).to eq true
        expect(json_response['data']['relationships']['products'].present?).to eq true
        expect(json_response['data']['relationships']['stock_locations'].present?).to eq true
        expect(json_response['data']['relationships']['photos'].present?).to eq true
        expect(json_response['data']['relationships']['logo'].present?).to eq true
      end
    end
  end

  describe 'vendor#index' do
    context 'with vendor state' do
      it 'only return active vendors' do
        active_vendor = create(:vendor, state: 'active')
        pending_vendor = create(:vendor, state: 'pending')
        blocked_vendor = create(:vendor, state: 'blocked')

        get "/api/v2/storefront/vendors"

        expect(json_response['data'].size).to eq 1
        expect(json_response['data'][0]['id']).to eq active_vendor.id.to_s
      end
    end
  end

  private

  def book_room(order, hotel: , price: 100, quantity: , from_date:, to_date:)
    room = hotel.variants.first
    order.line_items.create(vendor_id: hotel.id, price: price, quantity: quantity, from_date: from_date, to_date: to_date, variant_id: room.id)
  end
end
