require 'spec_helper'

RSpec.describe Spree::Api::V2::Storefront::InventoryController, type: :request do
  let(:product) { create(:product, product_type: 'accommodation') }
  let(:variant) { create(:variant, product: product) }
  let(:inventory_unit) { create(:inventory_unit, variant: variant) }
  let(:valid_headers) { { 'CONTENT_TYPE' => 'application/json' } }

  describe 'GET #index' do
    context 'when inventory fetch is successful' do
      let(:fetching_params) do
        {
          product_id: product.id,
          trip_date: '2025-04-01',
          check_in: '2025-04-01',
          check_out: '2025-04-03',
          num_guests: 2,
          service_type: 'accommodation'
        }
      end

      before do
        # set_application_token

        allow(SpreeCmCommissioner::InventoryFetcher).to receive(:call).and_return(
          double(success?: true, results: product.variants)
        )
      end

      it 'returns serialized inventory data' do
        get "/api/v2/storefront/inventory", params: fetching_params, headers: valid_headers

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to have_key('data')
      end
    end

    context 'when inventory fetch fails' do
      let(:fetching_params) { { product_id: product.id, service_type: 'accommodation' } }

      before do
        allow(SpreeCmCommissioner::InventoryFetcher).to receive(:call).and_return(
          double(success?: false, message: 'Inventory not available')
        )
      end

      it 'returns an error with status 400' do
        get "/api/v2/storefront/inventory", params: fetching_params, headers: valid_headers

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Inventory not available' })
      end
    end

    context 'when product is not found' do
      it 'raises a not found error' do
        get "/api/v2/storefront/inventory", params: { product_id: 'non-existent' }, headers: valid_headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST #book' do
    context 'when booking is successful' do
      let(:booking_params) do
        {
          product_id: product.id,
          variant_id: variant.id,
          check_in: '2025-04-01',
          check_out: '2025-04-03',
          quanity: 1,
          service_type: 'accommodation'
        }.to_json
      end

      before do
        # set_resource_owner_token

        allow(SpreeCmCommissioner::BookingHandler).to receive(:call).and_return(
          double(success?: true)
        )
      end

      it 'returns success message with status 201' do
        post "/api/v2/storefront/inventory/book", params: booking_params, headers: valid_headers

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to eq({ 'message' => 'Booking successful' })
      end
    end

    context 'when booking fails' do
      let(:booking_params) do
        {
          product_id: product.id,
          variant_id: variant.id,
          service_type: 'accommodation'
        }.to_json
      end

      before do
        allow(SpreeCmCommissioner::BookingHandler).to receive(:call).and_return(
          double(success?: false, message: 'Booking unavailable')
        )
      end

      it 'returns an error with status 422' do
        post "/api/v2/storefront/inventory/book", params: booking_params, headers: valid_headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Booking unavailable' })
      end
    end

    context 'when variant is not found' do
      let(:booking_params) do
        {
          product_id: product.id,
          variant_id: 'non-existent',
          service_type: 'accommodation'
        }.to_json
      end

      it 'raises a not found error' do
        post "/api/v2/storefront/inventory/book", params: booking_params, headers: valid_headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
