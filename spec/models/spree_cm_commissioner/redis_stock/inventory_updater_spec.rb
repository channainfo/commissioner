require 'spec_helper'

RSpec.describe SpreeCmCommissioner::RedisStock::InventoryUpdater do
  let(:redis) { double('Redis') }
  let(:redis_pool) { double('RedisPool') }
  let(:real_redis) { Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379/1') }
  let(:line_item_ids) { [1, 2] }
  let(:line_items) do
    [
      instance_double(Spree::LineItem, id: 1, variant_id: 101, quantity: 2),
      instance_double(Spree::LineItem, id: 2, variant_id: 102, quantity: 3)
    ]
  end
  let(:cached_inventory_items) do
    [
      instance_double(SpreeCmCommissioner::CachedInventoryItem,
                      inventory_key: 'inventory:1',
                      quantity_available: 2,
                      inventory_item_id: 1,
                      variant_id: 101),
      instance_double(SpreeCmCommissioner::CachedInventoryItem,
                      inventory_key: 'inventory:2',
                      quantity_available: 3,
                      inventory_item_id: 2,
                      variant_id: 102)
    ]
  end

  subject { described_class.new(line_item_ids) }

  before do
    allow(Spree::LineItem).to receive(:where).with(id: line_item_ids).and_return(line_items)
    allow(SpreeCmCommissioner::RedisStock::LineItemsCachedInventoryItemsBuilder)
      .to receive(:new).with(line_item_ids: line_item_ids).and_return(double(call: { 1 => cached_inventory_items }))
    allow(SpreeCmCommissioner).to receive(:redis_pool).and_return(redis_pool)
    allow(redis_pool).to receive(:with).and_yield(redis)
  end

  describe '#unstock!' do
    context 'when stock is sufficient' do
      before do
        allow(redis).to receive(:eval).and_return(1)
        allow(SpreeCmCommissioner::InventoryItemSyncerJob).to receive(:perform_later)
      end

      it 'unstocks inventory successfully' do
        expect(redis).to receive(:eval).with(subject.send(:unstock_redis_script),
                                            keys: ['inventory:1', 'inventory:2'],
                                            argv: [2, 3])
        expect(SpreeCmCommissioner::InventoryItemSyncerJob).to receive(:perform_later).with(
          inventory_id_and_quantities: [
            { inventory_id: 1, quantity: -2 },
            { inventory_id: 2, quantity: -3 }
          ]
        )

        subject.unstock!
      end
    end

    context 'when stock is insufficient' do
      before do
        allow(redis).to receive(:eval).and_return(0)
      end

      it 'raises UnableToUnstock error' do
        expect {
          subject.unstock!
        }.to raise_error(SpreeCmCommissioner::RedisStock::InventoryUpdater::UnableToUnstock,
                        Spree.t(:insufficient_stock_lines_present))
      end
    end
  end

  describe '#restock!' do
    before do
      allow(redis).to receive(:eval).and_return(1)
      allow(SpreeCmCommissioner::InventoryItemSyncerJob).to receive(:perform_later)
    end

    it 'restocks inventory successfully' do
      expect(redis).to receive(:eval).with(subject.send(:restock_redis_script),
                                          keys: ['inventory:1', 'inventory:2'],
                                          argv: [2, 3])
      expect(SpreeCmCommissioner::InventoryItemSyncerJob).to receive(:perform_later).with(
        inventory_id_and_quantities: [
          { inventory_id: 1, quantity: 2 },
          { inventory_id: 2, quantity: 3 }
        ]
      )

      subject.restock!
    end

    context 'when restock fails' do
      before do
        allow(redis).to receive(:eval).and_return(0)
      end

      it 'raises UnableToRestock error' do
        expect {
          subject.restock!
        }.to raise_error(SpreeCmCommissioner::RedisStock::InventoryUpdater::UnableToRestock)
      end
    end
  end

  context 'with real Redis' do
    before do
      # Set up initial Redis state
      real_redis.set('inventory:1', 10) # Sufficient stock for quantity 2
      real_redis.set('inventory:2', 10) # Sufficient stock for quantity 3

      # Override redis_pool to yield real_redis
      allow(redis_pool).to receive(:with).and_yield(real_redis)
      allow(SpreeCmCommissioner::InventoryItemSyncerJob).to receive(:perform_later)
    end

    after do
      # Clean up Redis keys
      real_redis.del('inventory:1', 'inventory:2')
    end

    describe '#unstock!' do
      it 'unstocks inventory and updates Redis' do
        expect {
          subject.unstock!
        }.to change {
          [real_redis.get('inventory:1').to_i, real_redis.get('inventory:2').to_i]
        }.from([10, 10]).to([8, 7])

        expect(SpreeCmCommissioner::InventoryItemSyncerJob).to have_received(:perform_later).with(
          inventory_id_and_quantities: [
            { inventory_id: 1, quantity: -2 },
            { inventory_id: 2, quantity: -3 }
          ]
        )
      end

      context 'when stock is insufficient' do
        before do
          real_redis.set('inventory:1', 1) # Insufficient for quantity 2
        end

        it 'raises UnableToUnstock error' do
          expect {
            subject.unstock!
          }.to raise_error(SpreeCmCommissioner::RedisStock::InventoryUpdater::UnableToUnstock,
                          Spree.t(:insufficient_stock_lines_present))
        end
      end
    end

    describe '#restock!' do
      it 'restocks inventory and updates Redis' do
        expect {
          subject.restock!
        }.to change {
          [real_redis.get('inventory:1').to_i, real_redis.get('inventory:2').to_i]
        }.from([10, 10]).to([12, 13])

        expect(SpreeCmCommissioner::InventoryItemSyncerJob).to have_received(:perform_later).with(
          inventory_id_and_quantities: [
            { inventory_id: 1, quantity: 2 },
            { inventory_id: 2, quantity: 3 }
          ]
        )
      end
    end
  end

  describe 'private methods' do
    describe '#unstock_redis_script' do
      it 'returns correct Lua script' do
        script = subject.send(:unstock_redis_script)
        expect(script).to include('local keys = KEYS')
        expect(script).to include('local quantities = ARGV')
        expect(script).to include("redis.call('DECRBY', key, tonumber(quantities[i]))")
      end
    end

    describe '#restock_redis_script' do
      it 'returns correct Lua script' do
        script = subject.send(:restock_redis_script)
        expect(script).to include('local keys = KEYS')
        expect(script).to include('local quantities = ARGV')
        expect(script).to include("redis.call('INCRBY', key, tonumber(quantities[i]))")
      end
    end

    describe '#extract_inventory_data' do
      it 'returns keys, quantities, and inventory_ids' do
        keys, quantities, inventory_ids = subject.send(:extract_inventory_data)
        expect(keys).to eq(['inventory:1', 'inventory:2'])
        expect(quantities).to eq([2, 3])
        expect(inventory_ids).to eq([1, 2])
      end
    end
  end
end
