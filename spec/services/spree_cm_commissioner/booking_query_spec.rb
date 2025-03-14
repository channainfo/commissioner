require 'spec_helper'

module SpreeCmCommissioner
  RSpec.describe BookingQuery do
    let(:variant) {create(:variant)}
    let(:variant_id) { variant.id }
    let(:service_type) { 'event' }
    let(:start_date) { Date.new(2025, 4, 1) }
    let(:end_date) { Date.new(2025, 4, 2) }
    let(:quantity) { 2 }

    subject { described_class.new(variant_id: variant_id, service_type: service_type) }

    describe '#initialize' do
      it 'sets variant_id and service_type' do
        expect(subject.instance_variable_get(:@variant_id)).to eq(variant_id)
        expect(subject.instance_variable_get(:@service_type)).to eq(service_type)
      end
    end

    describe '#book_inventory!' do
      let(:inventory_ids) { [1, 2, 3] }
      let(:inventory_keys) { inventory_ids.map { |id| "inventory:#{id}" } }

      before do
        allow(subject).to receive(:fetch_available_inventory).and_return(inventory_ids)
        allow(subject).to receive(:generate_inventory_keys).and_return(inventory_keys)
      end

      context 'when inventory reservation succeeds' do
        before do
          allow(subject).to receive(:reserve_inventory).and_return(true)
          allow(subject).to receive(:schedule_sync_inventory)
        end

        it 'returns true' do
          expect(subject.book_inventory!(start_date, end_date, quantity)).to be true
        end

        it 'schedules inventory sync' do
          expect(subject).to receive(:schedule_sync_inventory).with(inventory_ids, quantity)
          subject.book_inventory!(start_date, end_date, quantity)
        end
      end

      context 'when inventory reservation fails' do
        before do
          allow(subject).to receive(:reserve_inventory).and_return(false)
        end

        it 'raises StandardError' do
          expect {
            subject.book_inventory!(start_date, end_date, quantity)
          }.to raise_error(StandardError, 'Not enough inventory available')
        end
      end
    end

    describe '#fetch_available_inventory' do
      let(:inventory_units) { double('inventory_units') }
      let(:scope) { double('scope') }

      before do
        allow(SpreeCmCommissioner::InventoryUnit).to receive(:for_service).and_return(scope)
        allow(scope).to receive(:where).and_return(scope)
        allow(scope).to receive(:pluck).and_return([1, 2, 3])
      end

      context 'with date range' do
        it 'queries with date range for non-event service' do
          subject = described_class.new(variant_id: variant_id, service_type: 'regular')
          expect(scope).to receive(:where).with(variant_id: variant_id).and_return(scope)
          expect(scope).to receive(:where).with(inventory_date: start_date..end_date.prev_day).and_return(scope)
          subject.send(:fetch_available_inventory, start_date, end_date)
        end
      end

      context 'for event service type' do
        it 'queries with nil inventory_date' do
          expect(scope).to receive(:where).with(variant_id: variant_id).and_return(scope)
          expect(scope).to receive(:where).with(inventory_date: nil).and_return(scope)
          subject.send(:fetch_available_inventory, start_date, end_date)
        end
      end
    end

    describe '#generate_inventory_keys' do
      it 'generates correct Redis keys' do
        inventory_ids = [1, 2, 3]
        expect(subject.send(:generate_inventory_keys, inventory_ids)).to eq(
          ['inventory:1', 'inventory:2', 'inventory:3']
        )
      end
    end

    describe '#reserve_inventory' do
      let(:redis) { double('redis') }
      let(:keys) { ['inventory:1', 'inventory:2'] }
      let(:redis_pool) { double('redis_pool') }

      before do
        allow(SpreeCmCommissioner).to receive(:redis_pool).and_return(redis_pool)
        allow(redis_pool).to receive(:with).and_yield(redis)
        allow(subject).to receive(:redis_transaction_result).with(redis, keys, quantity).and_return(1)
      end

      it 'executes transaction and returns result' do
        result = subject.send(:reserve_inventory, keys, quantity)
        expect(result).to be true
      end
    end

    describe '#redis_transaction_result' do
      let(:redis) { double('redis') }
      let(:keys) { ['inventory:1'] }
      let(:script) { subject.send(:inventory_update_script) }

      it 'evals Lua script with correct parameters' do
        expect(redis).to receive(:eval).with(script, keys: keys, argv: [quantity]).and_return(1)
        subject.send(:redis_transaction_result, redis, keys, quantity)
      end
    end

    describe '#inventory_update_script' do
      it 'returns valid Lua script' do
        script = subject.send(:inventory_update_script)
        expect(script).to be_a(String)
        expect(script).to include('redis.call')
        expect(script).to include('DECRBY')
      end
    end

    describe '#schedule_sync_inventory' do
      let(:inventory_ids) { [1, 2, 3] }

      it 'schedules SyncInventoryJob' do
        expect(SyncInventoryJob).to receive(:perform_later).with(inventory_ids, quantity)
        subject.send(:schedule_sync_inventory, inventory_ids, quantity)
      end
    end
  end
end
