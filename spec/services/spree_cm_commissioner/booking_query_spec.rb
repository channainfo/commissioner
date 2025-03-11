require 'spec_helper'
require 'redis'

module SpreeCmCommissioner
  RSpec.describe BookingQuery do
    let(:variant) {create(:variant)}
    let(:variant_id) { variant.id }
    let(:service_type) { 'event' }
    let(:start_date) { Date.today }
    let(:end_date) { Date.today + 1.week }
    let(:quantity) { 2 }
    let(:inventory_ids) { [1, 2, 3] }
    let(:inventory_keys) { inventory_ids.map { |id| "inventory:#{id}" } }
    let(:redis) { Redis.new }

    subject { described_class.new(variant_id: variant_id, service_type: service_type) }

    before do
      allow(Redis).to receive(:new).and_return(redis)
      allow(redis).to receive(:pipelined).and_call_original
    end

    describe '#book_inventory' do
      context 'when there is enough inventory' do
        before do
          allow(subject).to receive(:find_inventory_ids).and_return(inventory_ids)
          allow(subject).to receive(:update_inventory_counts_in_redis).and_return(true)
          allow(subject).to receive(:enqueue_sync_inventory_unit)
        end

        it 'returns true' do
          expect(subject.book_inventory(start_date, end_date, quantity)).to be true
        end

        it 'calls enqueue_sync_inventory_unit' do
          expect(subject).to receive(:enqueue_sync_inventory_unit).with(inventory_ids, quantity)
          subject.book_inventory(start_date, end_date, quantity)
        end
      end

      context 'when there is not enough inventory' do
        before do
          allow(subject).to receive(:find_inventory_ids).and_return(inventory_ids)
          allow(subject).to receive(:update_inventory_counts_in_redis).and_return(false)
        end

        it 'raises an error' do
          expect { subject.book_inventory(start_date, end_date, quantity) }.to raise_error("Not enough inventory")
        end
      end
    end

    describe '#find_inventory_ids' do
      let(:scope) { double('InventoryUnitScope') }

      before do
        allow(SpreeCmCommissioner::InventoryUnit).to receive(:for_service).with(service_type).and_return(scope)
        allow(scope).to receive(:where).with(variant_id: variant_id).and_return(scope)
        allow(scope).to receive(:where).with(inventory_date: start_date..end_date.prev_day).and_return(scope)
        allow(scope).to receive(:where).with(inventory_date: nil).and_return(scope)
        allow(scope).to receive(:pluck).with(:id).and_return(inventory_ids)
      end

      it 'returns inventory IDs' do
        expect(subject.send(:find_inventory_ids, start_date, end_date)).to eq(inventory_ids)
      end
    end

    describe '#update_inventory_counts_in_redis' do
      context 'when inventory update is successful' do
        before do
          allow(subject).to receive(:decrease_quantity_inventory_in_redis).and_return([1, 2, 3])
        end

        it 'returns true' do
          expect(subject.send(:update_inventory_counts_in_redis, inventory_keys, quantity)).to be true
        end
      end

      context 'when inventory update fails' do
        before do
          allow(subject).to receive(:decrease_quantity_inventory_in_redis).and_return([-1, 2, 3])
          allow(subject).to receive(:rollback_inventory_updates)
        end

        it 'returns false' do
          expect(subject.send(:update_inventory_counts_in_redis, inventory_keys, quantity)).to be false
        end

        it 'calls rollback_inventory_updates' do
          expect(subject).to receive(:rollback_inventory_updates).with(inventory_keys, quantity)
          subject.send(:update_inventory_counts_in_redis, inventory_keys, quantity)
        end
      end
    end

    describe '#decrease_quantity_inventory_in_redis' do
      # let(:pipeline) { double('RedisPipeline') }
      let(:redis) { Redis.new }

      before do
        # allow(redis).to receive(:pipelined).and_yield(Redis::Future)
        # allow(pipeline).to receive(:decrby).with(inventory_keys[0], quantity).and_return(1)
        # allow(pipeline).to receive(:decrby).with(inventory_keys[1], quantity).and_return(2)
        # allow(pipeline).to receive(:decrby).with(inventory_keys[2], quantity).and_return(3)
        # redis.set(inventory_keys[0], 1)
        # redis.set(inventory_keys[1], 2)
        # redis.set(inventory_keys[3], 3)

        redis.set("inventory:1", 10)
        redis.set("inventory:2", 15)
      end

      after do
        redis.flushdb # Clean up after test
      end

      # Todo: fix spec
      # it 'returns updated counts' do
      #   keys = ["inventory:1", "inventory:2"]
      #   quantity = 3

      #   result = subject.send(:decrease_quantity_inventory_in_redis, keys, quantity)

      #   expect(result).to eq([7, 12])  # Expected results after decrementing by 3
      #   expect(redis.get("inventory:1").to_i).to eq(7)
      #   expect(redis.get("inventory:2").to_i).to eq(12)
      #   # expect(subject.send(:decrease_quantity_inventory_in_redis, inventory_keys, quantity)).to eq([1])
      # end
    end

    describe '#rollback_inventory_updates' do
      let(:pipeline) { double('RedisPipeline') }

      before do
        allow(redis).to receive(:pipelined).and_yield(pipeline)
        allow(pipeline).to receive(:incrby).with(inventory_keys[0], quantity).and_return(1)
        allow(pipeline).to receive(:incrby).with(inventory_keys[1], quantity).and_return(2)
        allow(pipeline).to receive(:incrby).with(inventory_keys[2], quantity).and_return(3)
      end

      it 'calls incrby for each key' do
        expect(pipeline).to receive(:incrby).exactly(inventory_keys.size).times
        subject.send(:rollback_inventory_updates, inventory_keys, quantity)
      end
    end

    describe '#enqueue_sync_inventory_unit' do
      it 'enqueues SyncInventoryJob' do
        expect(SyncInventoryJob).to receive(:perform_later).with(inventory_ids, quantity)
        subject.send(:enqueue_sync_inventory_unit, inventory_ids, quantity)
      end
    end
  end
end
