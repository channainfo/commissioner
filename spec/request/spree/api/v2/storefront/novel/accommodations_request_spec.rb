require 'spec_helper'

RSpec.describe Spree::Api::V2::Storefront::Novel::AccommodationsController, type: :request do
  let(:state) { create(:state, id: 1) }
  let(:vendor) { create(:cm_vendor, state: 'active', primary_product_type: :accommodation, default_state_id: state.id) }
  let(:variant) { create(:variant, vendor: vendor) }
  let(:valid_attributes) do
    {
      from_date: Date.today.to_s,
      to_date: (Date.today + 2.days).to_s,
      state_id: state.id,
      number_of_adults: 2,
      number_of_kids: 1
    }
  end

  before do
    create(:cm_inventory_item,
      variant_id: variant.id,
      inventory_date: Date.today,
      max_capacity: 3,
      quantity_available: 1,
      product_type: 'accommodation'
    )
    create(:cm_inventory_item,
      variant_id: variant.id,
      inventory_date: Date.today + 1.day,
      max_capacity: 3,
      quantity_available: 1,
      product_type: 'accommodation'
    )
  end

  describe 'GET /api/v2/storefront/novel/accommodations' do
    context 'with valid parameters' do
      before do
        get '/api/v2/storefront/novel/accommodations', params: valid_attributes
      end

      it 'returns a successful response' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns accommodations in JSON format' do
        expect(response.content_type).to include('application/vnd.api+json')
        json_response = JSON.parse(response.body)
        expect(json_response['data']).to be_present
      end

      it 'uses the AccommodationSerializer for the collection' do
        json_response = JSON.parse(response.body)
        expect(json_response['data'].first['type']).to eq('vendor')
        # Add more specific assertions based on your serializer's attributes
      end
    end

    context 'with invalid date parameters' do
      it 'returns an error for invalid date format' do
        get '/api/v2/storefront/novel/accommodations', params: valid_attributes.merge(from_date: 'invalid-date')
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to be_present
      end
    end

    context 'with sorting parameters' do
      it 'allows sorting by min_price' do
        get '/api/v2/storefront/novel/accommodations', params: valid_attributes.merge(sort: 'min_price')
        expect(response).to have_http_status(:ok)
      end

      it 'allows sorting by max_price' do
        get '/api/v2/storefront/novel/accommodations', params: valid_attributes.merge(sort: 'max_price')
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /api/v2/storefront/novel/accommodations/:id' do
    context 'with valid id' do
      before do
        get "/api/v2/storefront/novel/accommodations/#{vendor.id}", params: valid_attributes
      end

      it 'returns a successful response' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the specific accommodation' do
        json_response = JSON.parse(response.body)
        expect(json_response['data']['id']).to eq(vendor.id.to_s)
        expect(json_response['data']['type']).to eq('vendor')
      end

      it 'uses the AccommodationSerializer for the resource' do
        json_response = JSON.parse(response.body)
        # Add specific assertions based on your serializer's attributes
        expect(json_response['data']['attributes']).to be_present
      end
    end

    context 'with invalid id' do
      it 'returns not found' do
        get "/api/v2/storefront/novel/accommodations/99999", params: valid_attributes
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to be_present
      end
    end
  end
end
