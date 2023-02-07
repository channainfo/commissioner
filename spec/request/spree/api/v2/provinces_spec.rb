require 'spec_helper'

describe 'API V2 Storefront Provinces Spec', type: :request do
  describe 'state#index' do
    let!(:siemreap) {create(:state, name: 'Siemreap', total_inventory: 0)}
    let!(:kompot) {create(:state, name: 'Kompot', total_inventory: 2)}
    let!(:kandal) {create(:state, name: 'Kandal', total_inventory: 2)}

    it 'returns only state that has total_inventory > 0' do
      get "/api/v2/storefront/provinces"
      json_response = JSON.parse(response.body)
      expect(json_response["data"].size).to eq 2
      expect(json_response["data"][0]['id']).to eq kompot.id.to_s
      expect(json_response["data"][1]['id']).to eq kandal.id.to_s
    end
  end
end
