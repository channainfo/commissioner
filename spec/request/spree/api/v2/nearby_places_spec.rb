require 'spec_helper'

describe 'API V2 Storefront Nearby Places Spec', type: :request do
  let(:place) { create(:cm_place) }
  let(:phnom_penh) { create(:state, name: 'Phnom Penh') }
  let!(:phnom_penh_hotel) { create(:cm_vendor_with_product, name: 'Phnom Penh Hotel', default_state_id: phnom_penh.id) }
  let!(:sokha_pp_hotel)   { create(:cm_vendor_with_product, name: 'Sokha Phnom Penh Hotel', default_state_id: phnom_penh.id, total_inventory: 20) }

  let(:json_response) { JSON.parse(response.body) }

  describe 'nearby_place#index' do
    context 'when hotels setup nearby places' do
      let!(:nearby_place) { create(:cm_vendor_place, vendor: phnom_penh_hotel, place: place) }

      before { get "/api/v2/storefront/vendors/#{phnom_penh_hotel.slug}/nearby_places" }

      it_behaves_like 'returns 200 HTTP status'
      it 'returns all nearby places for phnom penh hotel' do
        expect(json_response["meta"]["count"]).to eq 1
      end
    end
    context 'when hotels does not setup nearby places' do
      before { get "/api/v2/storefront/vendors/#{sokha_pp_hotel.slug}/nearby_places" }

      it_behaves_like 'returns 200 HTTP status'
      it 'returns 0 nearby places for sokha hotel' do
        expect(json_response["meta"]["count"]).to eq 0
      end
    end
  end
end
