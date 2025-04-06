# spec/requests/spree/api/v2/storefront/inventory_item_spec.rb
require 'spec_helper'

RSpec.describe 'Spree::Api::V2::Storefront::InventoryItemController', type: :request do
  let(:product) { create(:product, product_type: 'accommodation') }
  let(:variant1) { create(:variant, product: product) }
  let(:variant2) { create(:variant, product: product) }
  let(:variant3) { create(:variant, product: product) }
  let(:variant_ids) { [variant1.id, variant2.id, variant3.id] }
  let(:json_response) { JSON.parse(response.body) }

  let(:trip_date) { Date.tomorrow.to_s }
  let(:check_in) { Date.tomorrow.to_s }
  let(:check_out) { (Date.tomorrow + 2).to_s }
  let(:num_guests) { '2' }

  describe 'GET /api/v2/storefront/inventory_item' do
    let(:product) { create(:product, product_type: 'bus') }

    context 'with product_type as bus' do
      let(:product_type) { 'bus' }

      before do
        create(:cm_inventory_item, variant: variant1, inventory_date: Date.tomorrow, quantity_available: 10, max_capacity: 12, product_type: variant1.product_type)
        create(:cm_inventory_item, variant: variant2, inventory_date: Date.tomorrow, quantity_available: 10, max_capacity: 12, product_type: variant2.product_type)
        create(:cm_inventory_item, variant: variant3, inventory_date: Date.tomorrow, quantity_available: 10, max_capacity: 12, product_type: variant3.product_type)
      end

      it 'returns paginated collection when trip_date is present' do
        get '/api/v2/storefront/inventory_item', params: {
          variant_ids: variant_ids,
          trip_date: trip_date,
          product_type: product_type
        }

        expect(response).to have_http_status(:ok)
        expect(json_response["data"].length).to eq(3)
      end

      it 'handles missing trip_date' do
        get '/api/v2/storefront/inventory_item', params: {
          variant_ids: variant_ids,
          product_type: product_type
        }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with product_type as accommodation' do
      let(:product_type) { 'accommodation' }

      before do
        create(:cm_inventory_item, variant: variant1, inventory_date: Date.tomorrow, quantity_available: 10, max_capacity: 12, product_type: product_type)
        create(:cm_inventory_item, variant: variant1, inventory_date: Date.tomorrow + 1, quantity_available: 5, max_capacity: 12, product_type: product_type)
        create(:cm_inventory_item, variant: variant1, inventory_date: Date.tomorrow + 2, quantity_available: 10, max_capacity: 12, product_type: product_type)

        create(:cm_inventory_item, variant: variant2, inventory_date: Date.tomorrow, quantity_available: 10, max_capacity: 12, product_type: product_type)
        create(:cm_inventory_item, variant: variant2, inventory_date: Date.tomorrow + 1, quantity_available: 2, max_capacity: 12, product_type: product_type)
        create(:cm_inventory_item, variant: variant2, inventory_date: Date.tomorrow + 2, quantity_available: 10, max_capacity: 12, product_type: product_type)

        create(:cm_inventory_item, variant: variant3, inventory_date: Date.tomorrow, quantity_available: 0, max_capacity: 12, product_type: product_type)
        create(:cm_inventory_item, variant: variant3, inventory_date: Date.tomorrow + 1, quantity_available: 5, max_capacity: 12, product_type: product_type)
        create(:cm_inventory_item, variant: variant3, inventory_date: Date.tomorrow + 2, quantity_available: 10, max_capacity: 12, product_type: product_type)
      end

      it 'returns paginated collection when check_in and check_out are present' do
        get '/api/v2/storefront/inventory_item', params: {
          variant_ids: variant_ids,
          check_in: check_in,
          check_out: check_out,
          num_guests: num_guests,
          product_type: product_type
        }

        expect(response).to have_http_status(:ok)
        expect(json_response['data'].pluck('attributes').pluck("variant_id")).to eq([variant1.id, variant2.id])
        expect(json_response['data'].pluck('attributes').pluck("quantity_available")).to eq([5, 2])
      end

      it 'handles missing check_in' do
        get '/api/v2/storefront/inventory_item', params: {
          variant_ids: variant_ids,
          check_out: check_out,
          product_type: product_type
        }

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'handles missing check_out' do
        get '/api/v2/storefront/inventory_item', params: {
          variant_ids: variant_ids,
          check_in: check_in,
          product_type: product_type
        }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with invalid inventory fetcher response' do
      let(:product_type) { 'accommodation' }
      let(:context) { double('context', success?: false, message: 'Invalid parameters') }

      before do
        allow(SpreeCmCommissioner::InventoryFetcher).to receive(:call).and_return(context)
      end

      it 'returns error response' do
        get '/api/v2/storefront/inventory_item', params: {
          variant_ids: variant_ids,
          product_type: product_type
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Invalid parameters' })
      end
    end

    context 'cache configuration' do
      let(:product_type) { 'bus' }
      let(:inventory_items) do
        [
          create(:cm_inventory_item, variant: variant1, inventory_date: Date.tomorrow, quantity_available: 10, max_capacity: 12, product_type: product_type),
          create(:cm_inventory_item, variant: variant2, inventory_date: Date.tomorrow, quantity_available: 10, max_capacity: 12, product_type: product_type),
          create(:cm_inventory_item, variant: variant3, inventory_date: Date.tomorrow, quantity_available: 10, max_capacity: 12, product_type: product_type)
        ]
      end
      let(:inventories) do
        inventory_items.map do |item|
          SpreeCmCommissioner::Inventory.new(item.slice(:variant_id, :inventory_date, :quantity_available, :max_capacity, :product_type))
        end
      end

      let(:context) { double('context', success?: true, results: inventories) }

      before do
        allow(SpreeCmCommissioner::InventoryFetcher).to receive(:call).and_return(context)
        # Stub resource_includes, sparse_fields, and serializer_params to return nil
        allow_any_instance_of(Spree::Api::V2::Storefront::InventoryItemController).to receive(:resource_includes).and_return(nil)
        allow_any_instance_of(Spree::Api::V2::Storefront::InventoryItemController).to receive(:sparse_fields).and_return(nil)
        allow_any_instance_of(Spree::Api::V2::Storefront::InventoryItemController).to receive(:serializer_params).and_return(nil)
      end

      it 'expects collection_cache_key to return the correct key for bus product type' do
        expected_key = Digest::MD5.hexdigest([
          'Spree::Api::V2::Storefront::InventoryItemController',
          inventories.map(&:variant_id),
          variant_ids.sort.join('-'),
          trip_date,
          nil, # check_in
          nil, # check_out
          nil, # num_gutes
          product_type,
          nil, # resource_includes
          nil, # sparse_fields
          nil, # serializer_params
          nil, # sort
          nil, # page
          nil  # per_page
        ].flatten.join('-'))

        expect_any_instance_of(Spree::Api::V2::Storefront::InventoryItemController).to receive(:collection_cache_key).with(Kaminari.paginate_array(inventories)).and_wrap_original do |method, collection|
          key = method.call(collection)
          expect(key).not_to eq('default_tax'), "Expected key not to be 'default_tax', but got #{key}"
          expect(key).to eq(expected_key), "Expected key to be #{expected_key}, but got #{key}"
          key
        end

        get '/api/v2/storefront/inventory_item', params: {
          variant_ids: variant_ids,
          trip_date: trip_date,
          product_type: product_type
        }

        expect(response).to have_http_status(:ok)
        expect(json_response['data'].length).to eq(3)
      end

      context 'with accommodation product type' do
        let(:product_type) { 'accommodation' }
        let(:inventory_items) do
          [
            create(:cm_inventory_item, variant: variant1, inventory_date: Date.tomorrow, quantity_available: 10, max_capacity: 12, product_type: product_type),
            create(:cm_inventory_item, variant: variant2, inventory_date: Date.tomorrow + 1, quantity_available: 2, max_capacity: 12, product_type: product_type)
          ]
        end

        it 'expects collection_cache_key to return the correct key for accommodation product type' do
          expected_key = Digest::MD5.hexdigest([
            'Spree::Api::V2::Storefront::InventoryItemController',
            inventories.map(&:variant_id),
            variant_ids.sort.join('-'),
            nil, # trip_date
            check_in,
            check_out,
            num_guests,
            product_type,
            nil, # resource_includes
            nil, # sparse_fields
            nil, # serializer_params
            nil, # sort
            nil, # page
            nil  # per_page
          ].flatten.join('-'))

          expect_any_instance_of(Spree::Api::V2::Storefront::InventoryItemController).to receive(:collection_cache_key).with(Kaminari.paginate_array(inventories)).and_wrap_original do |method, collection|
            key = method.call(collection)
            expect(key).not_to eq('default_tax'), "Expected key not to be 'default_tax', but got #{key}"
            expect(key).to eq(expected_key), "Expected key to be #{expected_key}, but got #{key}"
            key
          end

          get '/api/v2/storefront/inventory_item', params: {
            variant_ids: variant_ids,
            checkin: check_in,
            checkout: check_out,
            num_guests: num_guests,
            product_type: product_type
          }

          expect(response).to have_http_status(:ok)
          expect(json_response['data'].length).to eq(2)
        end
      end
    end
  end
end
