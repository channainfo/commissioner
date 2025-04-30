require 'spec_helper'

RSpec.describe Spree::Api::V2::Storefront::Accommodations::VariantsController, type: :request do
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

  describe 'GET /api/v2/storefront/novel/accommodations/:accommodation_id/variants' do
    let(:valid_params) do
      {
        from_date: from_date.to_s,
        to_date: to_date.to_s,
        accommodation_id: vendor.id,
        number_of_adults: 2,
        number_of_kids: 1
      }
    end

    context 'with valid parameters' do
      before do
        get "/api/v2/storefront/novel/accommodations/#{vendor.id}/variants", params: valid_params
      end

      it 'returns a successful response' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns a JSON response with variant data' do
        expect(json_response_body['data']).to be_present
        expect(json_response_body['data']).to be_an(Array)
        expect(json_response_body['data'].first['type']).to eq('variant')
        expect(json_response_body['data'].first['id']).to eq(variant.id.to_s)
        expect(json_response_body['data'].first['attributes']).to include(
          'sku' => variant.sku,
          'price' => variant.price.to_s
        )
      end
    end

    context 'with missing required parameters' do
      before do
        get "/api/v2/storefront/novel/accommodations/#{vendor.id}/variants", params: { accommodation_id: vendor.id }
      end

      it 'returns a bad request response' do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response_body['error']).to be_present
      end
    end

    context 'with no matching variants' do
      let(:other_vendor) do
        create(:cm_vendor,
          default_state: state,
          primary_product_type: :accommodation,
          state: :active
        )
      end
      let(:params_with_different_vendor) { valid_params.merge(accommodation_id: other_vendor.id) }

      before do
        get "/api/v2/storefront/novel/accommodations/#{other_vendor.id}/variants", params: params_with_different_vendor
      end

      it 'returns an empty collection' do
        expect(response).to have_http_status(:ok)
        expect(json_response_body['data']).to be_empty
      end
    end
  end

  describe 'GET /api/v2/storefront/novel/accommodations/:accommodation_id/variants/:id' do
    let(:valid_params) do
      {
        from_date: from_date.to_s,
        to_date: to_date.to_s,
        number_of_adults: 2,
        number_of_kids: 1
      }
    end

    context 'with a valid ID' do
      before do
        get "/api/v2/storefront/novel/accommodations/#{vendor.id}/variants/#{variant.id}", params: valid_params
      end

      it 'returns a successful response' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the specific variant as JSON' do
        expect(json_response_body['data']).to be_present
        expect(json_response_body['data']['id']).to eq(variant.id.to_s)
        expect(json_response_body['data']['type']).to eq('variant')
        expect(json_response_body['data']['attributes']).to include(
          'sku' => variant.sku,
          'price' => variant.price.to_s
        )
      end
    end

    context 'with an invalid ID' do
      let(:other_vendor) do
        create(:cm_vendor,
          default_state: create(:state, id: 2),
          primary_product_type: :accommodation,
          state: :active
        )
      end
      let(:product) { create(:product, vendor: other_vendor, product_type: 'accommodation') }
      let(:invalid_variant) { create(:cm_variant, number_of_adults: 2, number_of_kids: 2, vendor: other_vendor, product: product) }

      before do
        (from_date..to_date.prev_day).each do |date|
          create(:cm_inventory_item,
            variant: invalid_variant,
            inventory_date: date,
            quantity_available: 5
          )
        end
        get "/api/v2/storefront/novel/accommodations/#{vendor.id}/variants/#{invalid_variant.id}", params: valid_params
      end

      it 'returns a not found response' do
        expect(response).to have_http_status(:not_found)
        expect(json_response_body['error']).to eq('The resource you were looking for could not be found.')
      end
    end
  end
end
