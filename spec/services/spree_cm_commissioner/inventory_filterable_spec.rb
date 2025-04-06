require 'spec_helper'

module SpreeCmCommissioner
  RSpec.describe InventoryFilterable do
    # Create a test class that includes the module
    let(:test_class) do
      Class.new do
        include SpreeCmCommissioner::InventoryFilterable
      end
    end

    let(:variant) { create(:variant) }
    let(:variant_id) { variant.id }
    let(:start_date) { Date.today.beginning_of_month }
    let(:end_date) { Date.today.end_of_month }
    let(:product_type) { 'event' }
    let(:inventory_item) { create(:cm_inventory_item, variant: variant, inventory_date: start_date, quantity_available: 10, max_capacity: 20, product_type: product_type )}
    let(:service) { test_class.new }
    let(:redis) { instance_double(Redis) }
    let(:redis_pool) { double('redis_pool') }

    before do
      allow(SpreeCmCommissioner).to receive(:redis_pool).and_return(redis_pool)
      allow(redis_pool).to receive(:with).and_yield(redis)
    end

    describe '#fetch_inventory_items' do
      context 'when there are cached inventory counts' do
        let(:inventory_rows) { [inventory_item] }
        let(:cached_counts) { ['10'] }

        before do
          allow(service).to receive(:build_scope).and_return(inventory_rows)
          allow(redis).to receive(:mget).and_return(cached_counts)
        end

        it 'returns the inventory with the cached count' do
          result = service.fetch_inventory_items([variant_id], start_date, end_date, product_type)

          expect(redis).to have_received(:mget)
          expect(result.first.quantity_available).to eq(10)
        end
      end

      context 'when there are no cached inventory counts' do
        let(:inventory_rows) { [inventory_item] }
        let(:cached_counts) { [nil] }

        before do
          allow(service).to receive(:build_scope).and_return(inventory_rows)
          allow(redis).to receive(:mget).and_return(cached_counts)
          allow(service).to receive(:cache_inventory)
        end

        it 'caches the inventory count and returns the inventory with the original quantity' do
          result = service.fetch_inventory_items([variant_id], start_date, end_date, product_type)

          expect(redis).to have_received(:mget)
          expect(service).to have_received(:cache_inventory)
          expect(result.first.quantity_available).to eq(inventory_item.quantity_available)
        end
      end

      context 'when no inventory rows are found' do
        before do
          allow(service).to receive(:build_scope).and_return([])
        end

        it 'returns an empty array' do
          result = service.fetch_inventory_items([variant_id], start_date, end_date, product_type)

          expect(result).to eq([])
        end
      end
    end

    describe 'private methods' do
      context '#build_scope' do
        context 'variant_id is []' do
          it "returns result without query variant_id" do
            inventory_item

            scope = service.send(:build_scope, [], start_date, end_date, product_type)
            expect(scope.to_a.length).to eq(1)
            expect(scope.to_a).to eq(InventoryItem.where(inventory_date: start_date..end_date.prev_day).to_a)
          end
        end

        it 'returns the correct scope when date range is provided' do
          inventory_item
          scope = service.send(:build_scope, [variant_id], start_date, end_date, product_type)

          expect(scope.to_a.length).to eq(1)
          expect(scope.to_a).to eq(InventoryItem.where(variant_id: [variant.id], inventory_date: start_date..end_date.prev_day).to_a)
        end

        it 'returns the correct scope when product_type is event' do
          inventory_item
          create(:cm_inventory_item, variant: variant, inventory_date: nil, quantity_available: 10, max_capacity: 20, product_type: product_type )
          product_type_event = 'event'
          scope = service.send(:build_scope, [variant_id], nil, nil, product_type_event)

          expect(scope.to_a.length).to eq(1)
          expect(scope.to_a).to eq(InventoryItem.where(variant_id: [variant.id], inventory_date: nil).to_a)
        end
      end

      context '#fetch_cached_counts' do
        let(:inventory_rows) { [inventory_item] }

        it 'fetches the cached counts from Redis' do
          keys = inventory_rows.map { |row| "inventory:#{row.id}" }
          allow(redis).to receive(:mget).and_return(['10'])

          cached_counts = service.send(:fetch_cached_counts, inventory_rows)

          expect(cached_counts).to eq(['10'])
          expect(redis).to have_received(:mget).with(*keys)
        end
      end

      context '#determine_quantity_available' do
        let(:cached_count) { '10' }

        it 'returns the cached quantity available if it exists' do
          result = service.send(:determine_quantity_available, inventory_item, cached_count)

          expect(result).to eq(10)
        end

        it 'caches the quantity if no cached count exists' do
          allow(redis).to receive(:set)
          result = service.send(:determine_quantity_available, inventory_item, nil)

          expect(result).to eq(inventory_item.quantity_available)
          expect(redis).to have_received(:set)
        end
      end

      context '#cache_inventory' do
        it 'sets the inventory count in Redis with expiration time' do
          key = "inventory:#{inventory_item.id}"
          expiration_in = service.send(:calculate_expiration_in_second, inventory_item.inventory_date)

          allow(redis).to receive(:set)

          service.send(:cache_inventory, inventory_item)

          expect(redis).to have_received(:set).with(key, inventory_item.quantity_available, ex: expiration_in)
        end
      end

      context '#calculate_expiration_in_second' do
        it 'calculates 1 year expiration for events' do
          expiration = service.send(:calculate_expiration_in_second, nil)

          expect(expiration).to eq(31_536_000)
        end

        it 'calculates the expiration based on inventory date' do
          inventory_date = Date.today + 1.day
          expiration = service.send(:calculate_expiration_in_second, inventory_date)

          expect(expiration).to be > 0
        end
      end
    end
  end
end
