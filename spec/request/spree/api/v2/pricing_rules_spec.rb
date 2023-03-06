require 'spec_helper'

describe 'API V2 Storefront Pricing Rules Spec', type: :request do
  let(:phnom_penh) { create(:state, name: 'Phnom Penh') }
  let!(:phnom_penh_hotel) { create(:cm_vendor_with_product, name: 'Phnom Penh Hotel', state_id: phnom_penh.id) }
  let!(:sokha_pp_hotel)   { create(:cm_vendor_with_product, name: 'Sokha Phnom Penh Hotel', state_id: phnom_penh.id) }

  let(:json_response) { JSON.parse(response.body) }

  describe 'pricing_rules#index' do
    describe 'when hotels setup pricing rules' do
      let!(:women_day_rule)    { create(:cm_vendor_pricing_rule, date_rule: { type: 'fixed_date', name: 'Women Day', value: '2023-03-05' }, length: 3, position: 1, vendor: phnom_penh_hotel) }
      let!(:water_policy_rule) { create(:cm_vendor_pricing_rule, date_rule: { type: 'fixed_date', name: 'Water Policy Day', value: '2023-03-04' }, length: 2, position: 2, vendor: phnom_penh_hotel) }

      context 'rules apply' do
        before { get "/api/v2/storefront/accommodations/#{phnom_penh_hotel.slug}/pricing_rules?from_date=2023-03-03&to_date=2023-03-09" }

        it_behaves_like 'returns 200 HTTP status'
        it 'returns all pricing rules including price by date for phnom penh hotel' do
          expect(json_response["data"][0]["attributes"]["price_by_dates"].count).to eq 3
          expect(json_response["data"][1]["attributes"]["price_by_dates"].count).to eq 2
          expect(json_response["meta"]["count"]).to eq 2
        end
      end

      context 'rules not apply' do
        before { get "/api/v2/storefront/accommodations/#{phnom_penh_hotel.slug}/pricing_rules?from_date=2023-03-20&to_date=2023-03-25" }

        it_behaves_like 'returns 200 HTTP status'
        it 'returns all pricing rules including price by date for phnom penh hotel' do
          expect(json_response["data"][0]["attributes"]["price_by_dates"].count).to eq 0
          expect(json_response["data"][1]["attributes"]["price_by_dates"].count).to eq 0
          expect(json_response["meta"]["count"]).to eq 2
        end
      end
    end

    context 'when hotels does not setup pricing rules' do
      before { get "/api/v2/storefront/accommodations/#{sokha_pp_hotel.slug}/pricing_rules?from_date=2023-03-09&to_date=2023-03-15" }

      it_behaves_like 'returns 200 HTTP status'
      it 'returns 0 pricing rules for sokha hotel' do
        expect(json_response["meta"]["count"]).to eq 0
      end
    end
  end
end
