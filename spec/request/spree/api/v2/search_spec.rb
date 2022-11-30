require 'spec_helper'

describe 'API V2 Storefront Vendor Search Spec', type: :request do

  let!(:vendor_pp) { create(:active_vendor, name: 'vendor_pp') }
  let!(:vendor_sr) { create(:active_vendor, name: 'vendor_sr') }
  let!(:siem_reap) { create(:state, name: 'Siemreap')}
  let!(:phnom_penh) { create(:state, name: 'Phnom Penh')}
  let!(:option_type) { create(:option_type, name: 'location', presentation: 'Location', attr_type: 'state_selection') }
  let!(:option_value_pp) { create(:option_value, option_type: option_type, presentation: phnom_penh.id) }
  let!(:option_value_sr) { create(:option_value, option_type: option_type, presentation: siem_reap.id) }
  let!(:stock_location_pp) { vendor_pp.stock_locations.first.update(state: phnom_penh)}
  let!(:stock_location_sr) { vendor_sr.stock_locations.first.update(state: siem_reap)}
  let!(:product1) {create(:product_in_stock, name: 'Bedroom 1', vendor: vendor_pp, price: 10 )}
  let!(:product1) {create(:product, name: 'Bedroom 1', vendor: vendor_sr, price: 10 )}
  let!(:product2) {create(:product_in_stock, name: 'Bedroom 2', vendor: vendor_sr, price: 10 )}

  describe 'search#index' do
    context 'with no param' do
      before { get '/api/v2/storefront/search' }

      it 'returns one vendor' do
        json_response = JSON.parse(response.body)

        expect(json_response["meta"]["count"]).to eq 2
      end
      it_behaves_like 'returns 200 HTTP status'
    end

    context 'with param province_id' do
      before { get "/api/v2/storefront/search", params: { province_id: siem_reap.id } }
      it_behaves_like 'returns 200 HTTP status'

      it 'returns one vendor' do
        json_response = JSON.parse(response.body)

        expect(json_response["meta"]["count"]).to eq 1
      end
    end
  end
end
