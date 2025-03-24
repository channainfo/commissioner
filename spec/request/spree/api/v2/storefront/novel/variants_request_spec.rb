require 'spec_helper'

RSpec.describe Spree::Api::V2::Storefront::Novel::VariantsController, type: :request do
  let(:vendor) { create(:vendor, id: 186) }
  let(:product) { create(:product, vendor: vendor) }
  let(:variant) { create(:variant, product: product, vendor: vendor) }
  let(:base_path) { '/api/v2/storefront/novel/accommodations/186/variants' }

  describe 'GET #index' do
    context 'with valid parameters' do
      let(:from_date) { Time.zone.today }
      let(:to_date) { Time.zone.today + 2 }
      let(:params) do
        {
          from_date: from_date.to_s,
          to_date: to_date.to_s,
          number_of_adults: 0,
          number_of_kids: 0,
          include: 'product'
        }
      end

      before do
        # Create available inventory for the variant
        create(:cm_inventory_item,
          variant: variant,
          inventory_date: from_date,
          quantity_available: 5
        )
        create(:cm_inventory_item,
          variant: variant,
          inventory_date: from_date + 1,
          quantity_available: 5
        )
      end

      it 'returns successful response with variants' do
        get base_path, params: params

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data']).to be_present
        expect(json_response['data']).to be_an(Array)
      end

      it 'includes product in the response when requested' do
        get base_path, params: params

        json_response = JSON.parse(response.body)
        expect(json_response['included']).to be_present
        expect(json_response['included'].any? { |inc| inc['type'] == 'product' }).to be true
      end

      it 'uses VariantSerializer for the collection' do
        get base_path, params: params

        json_response = JSON.parse(response.body)
        variant_data = json_response['data'].first
        expect(variant_data['type']).to eq('variant')
        expect(variant_data['attributes']).to be_present
      end
    end

    context 'with no available variants' do
      let(:from_date) { Time.zone.today }
      let(:to_date) { Time.zone.today + 2 }
      let(:params) do
        {
          from_date: from_date.to_s,
          to_date: to_date.to_s,
          number_of_adults: 0,
          number_of_kids: 0
        }
      end

      it 'returns empty collection' do
        get base_path, params: params

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data']).to be_empty
      end
    end
  end

  describe 'GET #show' do
    let(:from_date) { Time.zone.today }
    let(:to_date) { Time.zone.today + 2 }
    let(:params) do
      {
        from_date: from_date.to_s,
        to_date: to_date.to_s,
        number_of_adults: 0,
        number_of_kids: 0,
        include: 'product'
      }
    end

    before do
      create(:cm_inventory_item,
        variant: variant,
        inventory_date: from_date,
        quantity_available: 5
      )
      create(:cm_inventory_item,
        variant: variant,
        inventory_date: from_date + 1,
        quantity_available: 5
      )
    end

    it 'returns specific variant' do
      get "#{base_path}/#{variant.id}", params: params

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['id']).to eq(variant.id.to_s)
      expect(json_response['data']['type']).to eq('variant')
    end

    it 'includes product when requested' do
      get "#{base_path}/#{variant.id}", params: params

      json_response = JSON.parse(response.body)
      expect(json_response['included']).to be_present
      expect(json_response['included'].any? { |inc| inc['type'] == 'product' }).to be true
    end
  end
end
