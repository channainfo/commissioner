require 'spec_helper'

RSpec.describe Spree::Api::V2::Storefront::AccommodationsController, type: :request do
  let(:state) { create(:state, id: 1) }
  let(:vendor) do
    create(:cm_vendor,
      default_state: state,
      primary_product_type: :accommodation,
      state: :active,
      min_price: 100,
      max_price: 200
    )
  end
  let(:variant) { create(:cm_variant, number_of_adults: 2, number_of_kids: 2, vendor: vendor) }
  let(:from_date) { Date.today }
  let(:to_date) { Date.today + 2.days }

  before do
    # Set up inventory for the variant
    (from_date..to_date.prev_day).each do |date|
      create(:cm_inventory_item,
        variant: variant,
        inventory_date: date,
        quantity_available: 5
      )
    end
  end

  describe 'GET /api/v2/storefront/accommodations' do
    let(:valid_params) do
      {
        from_date: from_date.to_s,
        to_date: to_date.to_s,
        state_id: state.id,
        number_of_adults: 2,
        number_of_kids: 1
      }
    end

    context 'with valid parameters' do
      before do
        get '/api/v2/storefront/accommodations', params: valid_params
      end

      it 'returns a successful response' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns a JSON response with vendor data' do
        expect(json_response_body['data']).to be_present
        expect(json_response_body['data']).to be_an(Array)
        expect(json_response_body['data'].first['type']).to eq('vendor')
        expect(json_response_body['data'].first['id']).to eq(vendor.id.to_s)
        expect(json_response_body['data'].first['attributes']).to include(
          'min_price' => vendor.min_price.to_s,
          'max_price' => vendor.max_price.to_s
        )
      end
    end

    context 'with missing required parameters' do
      before do
        get '/api/v2/storefront/accommodations', params: { state_id: state.id }
      end

      it 'returns a bad request response' do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response_body['error']).to be_present
      end
    end

    context 'with sorting by min_price' do
      let(:vendor2) do
        create(:cm_vendor,
          default_state: state,
          primary_product_type: :accommodation,
          state: :active,
          min_price: 50,
          max_price: 150
        )
      end
      let(:product) { create(:cm_product, vendor: vendor, product_type: 'accommodation') }
      let(:variant2) { create(:cm_variant, number_of_adults: 2, number_of_kids: 2, vendor: vendor2, product: product) }

      before do
        (from_date..to_date.prev_day).each do |date|
          create(:cm_inventory_item,
            variant: variant2,
            inventory_date: date,
            quantity_available: 5
          )
        end
        get '/api/v2/storefront/accommodations', params: valid_params.merge(sort: 'min_price')
      end

      it 'returns vendors sorted by min_price asc' do
        expect(response).to have_http_status(:ok)
        expect(json_response_body['data'].map { |d| d['id'] }).to eq([vendor.id.to_s, vendor2.id.to_s])
      end
    end

    context 'with no matching vendors' do
      let(:other_state) { create(:state, id: 2) }
      let(:params_with_different_state) { valid_params.merge(state_id: other_state.id) }

      before do
        get '/api/v2/storefront/accommodations', params: params_with_different_state
      end

      it 'returns an empty collection' do
        expect(response).to have_http_status(:ok)
        expect(json_response_body['data']).to be_empty
      end
    end
  end

  describe 'GET /api/v2/storefront/accommodations/:id' do
    let(:valid_params) do
      {
        from_date: from_date.to_s,
        to_date: to_date.to_s,
        state_id: state.id,
        number_of_adults: 2,
        number_of_kids: 1
      }
    end

    context 'with a valid ID' do
      before do
        get "/api/v2/storefront/accommodations/#{vendor.id}", params: valid_params
      end

      it 'returns a successful response' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the specific vendor as JSON' do
        expect(json_response_body['data']).to be_present
        expect(json_response_body['data']['id']).to eq(vendor.id.to_s)
        expect(json_response_body['data']['type']).to eq('vendor')
        expect(json_response_body['data']['attributes']).to include(
          'min_price' => vendor.min_price.to_s,
          'max_price' => vendor.max_price.to_s
        )
      end
    end

    context 'with an invalid ID' do
      let(:invalid_vendor) do
        create(:vendor,
          default_state: create(:state, id: 2),
          primary_product_type: :accommodation,
          state: :active
        )
      end

      before do
        get "/api/v2/storefront/accommodations/#{invalid_vendor.id}", params: valid_params
      end

      it 'returns a not found response' do
        expect(response).to have_http_status(:not_found)
        expect(json_response_body['error']).to eq('The resource you were looking for could not be found.')
      end
    end
  end
end
