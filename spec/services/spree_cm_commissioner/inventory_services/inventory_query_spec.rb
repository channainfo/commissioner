require "spec_helper"

module SpreeCmCommissioner
  RSpec.describe InventoryServices::InventoryQuery, type: :model do
    let(:variant) { create(:cm_variant) }
    let(:variant_id) { variant.id }
    let(:start_date) { Date.today.beginning_of_month }
    let(:end_date) { Date.today.end_of_month }
    let(:service_type) { 'event' }
    let(:inventory_unit) { create(:cm_inventory_unit, variant: variant, inventory_date: start_date, quantity_available: 10, max_capacity: 20, service_type: service_type )}
    let(:service) { described_class.new }
    let(:redis) { instance_double(Redis) }

    before do
      allow(service).to receive(:redis).and_return(redis)
    end

    describe '#fetch_available_inventory' do
      context 'when there are cached inventory counts' do
        let(:inventory_rows) { [inventory_unit] }
        let(:cached_counts) { ['10'] }

        before do
          allow(service).to receive(:build_scope).and_return(inventory_rows)
          allow(redis).to receive(:mget).and_return(cached_counts)
        end

        it 'returns the inventory with the cached count' do
          result = service.fetch_available_inventory(variant_id, start_date, end_date, service_type)

          expect(redis).to have_received(:mget)
          expect(result.first.quantity_available).to eq(10)
        end
      end

      context 'when there are no cached inventory counts' do
        let(:inventory_rows) { [inventory_unit] }
        let(:cached_counts) { [nil] }

        before do
          allow(service).to receive(:build_scope).and_return(inventory_rows)
          allow(redis).to receive(:mget).and_return(cached_counts)
          allow(service).to receive(:cache_inventory)
        end

        it 'caches the inventory count and returns the inventory with the original quantity' do
          result = service.fetch_available_inventory(variant_id, start_date, end_date, service_type)

          expect(redis).to have_received(:mget)
          expect(service).to have_received(:cache_inventory)
          expect(result.first.quantity_available).to eq(inventory_unit.quantity_available)
        end
      end

      context 'when no inventory rows are found' do
        before do
          allow(service).to receive(:build_scope).and_return([])
        end

        it 'returns an empty array' do
          result = service.fetch_available_inventory(variant_id, start_date, end_date, service_type)

          expect(result).to eq([])
        end
      end
    end

    describe 'private methods' do
      context '#build_scope' do
        context 'variant_id is nil' do
          it "returns result without query variant_id" do
            inventory_unit

            scope = service.send(:build_scope, nil, start_date, end_date, service_type)
            expect(scope.to_a.length).to eq(1)
            expect(scope.to_a).to eq(InventoryUnit.where(inventory_date: start_date..end_date.prev_day).to_a)
          end
        end

        it 'returns the correct scope when date range is provided' do
          inventory_unit
          scope = service.send(:build_scope, variant_id, start_date, end_date, service_type)

          expect(scope.to_a.length).to eq(1)
          expect(scope.to_a).to eq(InventoryUnit.where(variant_id: variant.id, inventory_date: start_date..end_date.prev_day).to_a)
        end

        it 'returns the correct scope when service_type is event' do
          inventory_unit
          create(:cm_inventory_unit, variant: variant, inventory_date: nil, quantity_available: 10, max_capacity: 20, service_type: service_type )
          service_type_event = 'event'
          scope = service.send(:build_scope, variant_id, nil, nil, service_type_event)

          expect(scope.to_a.length).to eq(1)
          expect(scope.to_a).to eq(InventoryUnit.where(variant_id: variant.id, inventory_date: nil).to_a)
        end
      end

      context '#fetch_cached_counts' do
        let(:inventory_rows) { [inventory_unit] }

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
          result = service.send(:determine_quantity_available, inventory_unit, cached_count)

          expect(result).to eq(10)
        end

        it 'caches the quantity if no cached count exists' do
          allow(redis).to receive(:set)
          result = service.send(:determine_quantity_available, inventory_unit, nil)

          expect(result).to eq(inventory_unit.quantity_available)
          expect(redis).to have_received(:set)
        end
      end

      context '#cache_inventory' do
        it 'sets the inventory count in Redis with expiration time' do
          key = "inventory:#{inventory_unit.id}"
          expiration_in = service.send(:calculate_expiration_in_second, inventory_unit.inventory_date)

          allow(redis).to receive(:set)

          service.send(:cache_inventory, inventory_unit)

          expect(redis).to have_received(:set).with(key, inventory_unit.quantity_available, ex: expiration_in)
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
