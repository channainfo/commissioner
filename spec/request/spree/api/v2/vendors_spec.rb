require 'spec_helper'

describe 'API V2 Storefront Vendor Spec', type: :request do

  let!(:vendor_logo) { create(:vendor_logo) }
  let!(:vendor) { create(:active_vendor, name: 'vendor', logo: vendor_logo) }

  describe 'vendors#show' do
    context 'with logo included' do
      before { get "/api/v2/storefront/vendors/#{vendor.slug}?include=logo" }

      it_behaves_like 'returns 200 HTTP status'

      it 'returns logo information' do
        json_response = JSON.parse(response.body)

        expect(json_response.keys).to contain_exactly('data', 'included')

        expect(json_response['included'].first['id']).to eq(vendor_logo.id.to_s)
        expect(json_response['included'].first['attributes']['styles'].length).to eq(2)
      end
    end

    context 'with attribute min and max price' do
      before { get "/api/v2/storefront/vendors/#{vendor.slug}" }

      it_behaves_like 'returns 200 HTTP status'

      it 'returns min and max price attribute' do
        json_response = JSON.parse(response.body)

        expect(json_response['data']['attributes']).to have_key('min_price')
        expect(json_response['data']['attributes']).to have_key('max_price')
      end
    end
  end
end
