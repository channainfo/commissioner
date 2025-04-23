require 'spec_helper'

RSpec.describe SpreeCmCommissioner::RedisStock::InventoryUpdater do
  let(:redis) { double('Redis') }
  let(:redis_pool) { double('RedisPool') }
  let(:real_redis) { Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379/1') }
  let(:line_item_ids) { [1, 2] }
  let(:inventory_builder) { instance_double(SpreeCmCommissioner::RedisStock::InventoryKeyQuantityBuilder) }
  let(:inventory_items) do
    [
      { inventory_key: 'inventory:1', purchase_quantity: 2, quantity_available: 5, inventory_item_id: 1 },
      { inventory_key: 'inventory:2', purchase_quantity: 1, quantity_available: 3, inventory_item_id: 2 }
    ]
  end
  let(:keys) { ['inventory:1', 'inventory:2'] }
  let(:quantities) { [2, 1] }
  let(:inventory_ids) { [1, 2] }

  subject { described_class.new(line_item_ids) }

  before do
    allow(SpreeCmCommissioner::RedisStock::InventoryKeyQuantityBuilder).to receive(:new).with(line_item_ids).and_return(inventory_builder)
    allow(inventory_builder).to receive(:call).and_return(inventory_items)
    allow(SpreeCmCommissioner).to receive(:redis_pool).and_return(redis_pool)
    allow(redis_pool).to receive(:with).and_yield(redis)
  end

  describe '#initialize' do
    it 'sets line_item_ids' do
      expect(subject.instance_variable_get(:@line_item_ids)).to eq(line_item_ids)
    end
  end

  describe '#unstock!' do
    before do
      allow(redis).to receive(:eval).and_return(1)
      allow(SpreeCmCommissioner::InventoryItemSyncerJob).to receive(:perform_later)
    end

    it 'unstocks inventory and schedules sync job' do
      expect(subject).to receive(:unstock).with(keys, quantities).and_return(true)
      expect(subject).to receive(:schedule_sync_inventory).with(inventory_ids, [-2, -1])
      subject.unstock!
    end

    context 'when unstock fails' do
      before do
        allow(redis).to receive(:eval).and_return(0)
      end

      it 'raises UnableToUnstock' do
        expect { subject.unstock! }.to raise_error(described_class::UnableToUnstock, Spree.t(:insufficient_stock_lines_present))
      end
    end

    context 'with real Redis', redis: true do
      before do
        allow(SpreeCmCommissioner).to receive(:redis_pool).and_return(real_redis)
        real_redis.set('inventory:1', 5)
        real_redis.set('inventory:2', 3)
        allow(SpreeCmCommissioner::InventoryItemSyncerJob).to receive(:perform_later)
      end

      after do
        real_redis.del('inventory:1', 'inventory:2')
      end

      it 'unstocks inventory and schedules sync job' do
        expect(SpreeCmCommissioner::InventoryItemSyncerJob).to receive(:perform_later).with(inventory_ids: [1, 2], quantities: [-2, -1])
        subject.unstock!
        expect(real_redis.get('inventory:1')).to eq('3') # 5 (Qty in redis) - 2 (Purchase quantity)
        expect(real_redis.get('inventory:2')).to eq('2') # 3 (Qty in redis) - 1 (Purchase quantity)
      end

      context 'when insufficient stock for one item' do
        before do
          real_redis.set('inventory:2', 0) # Insufficient for purchase_quantity: 1
        end

        it 'raises UnableToUnstock and does not modify Redis' do
          expect { subject.unstock! }.to raise_error(described_class::UnableToUnstock, Spree.t(:insufficient_stock_lines_present))
          expect(real_redis.get('inventory:1')).to eq('5')
          expect(real_redis.get('inventory:2')).to eq('0')
        end
      end

      context 'when insufficient stock for multiple items' do
        before do
          real_redis.set('inventory:1', 1) # Insufficient for purchase_quantity: 2
          real_redis.set('inventory:2', 0) # Insufficient for purchase_quantity: 1
        end

        it 'raises UnableToUnstock and does not modify Redis' do
          expect { subject.unstock! }.to raise_error(described_class::UnableToUnstock, Spree.t(:insufficient_stock_lines_present))
          expect(real_redis.get('inventory:1')).to eq('1')
          expect(real_redis.get('inventory:2')).to eq('0')
        end
      end
    end
  end

  describe '#restock!' do
    before do
      allow(redis).to receive(:eval).and_return(1)
      allow(SpreeCmCommissioner::InventoryItemSyncerJob).to receive(:perform_later)
    end

    it 'restocks inventory and schedules sync job' do
      expect(subject).to receive(:restock).with(keys, quantities).and_return(true)
      expect(subject).to receive(:schedule_sync_inventory).with(inventory_ids, [2, 1])
      subject.restock!
    end

    context 'when restock fails' do
      before do
        allow(redis).to receive(:eval).and_return(0)
      end

      it 'raises UnableToRestock' do
        expect { subject.restock! }.to raise_error(described_class::UnableToRestock)
      end
    end

    context 'with real Redis', redis: true do
      before do
        allow(SpreeCmCommissioner).to receive(:redis_pool).and_return(real_redis)
        real_redis.set('inventory:1', 5)
        real_redis.set('inventory:2', 3)
        allow(SpreeCmCommissioner::InventoryItemSyncerJob).to receive(:perform_later)
      end

      after do
        real_redis.del('inventory:1', 'inventory:2')
      end

      it 'restocks inventory and schedules sync job' do
        expect(SpreeCmCommissioner::InventoryItemSyncerJob).to receive(:perform_later).with(inventory_ids: [1, 2], quantities: [2, 1])
        subject.restock!
        expect(real_redis.get('inventory:1')).to eq('7')
        expect(real_redis.get('inventory:2')).to eq('4')
      end
    end
  end

  describe '#unstock' do
    it 'evaluates unstock Redis script and returns true on success' do
      expect(redis).to receive(:eval).with(subject.send(:unstock_redis_script), keys: keys, argv: quantities).and_return(1)
      expect(subject.send(:unstock, keys, quantities)).to be true
    end

    it 'returns false on failure' do
      expect(redis).to receive(:eval).with(subject.send(:unstock_redis_script), keys: keys, argv: quantities).and_return(0)
      expect(subject.send(:unstock, keys, quantities)).to be false
    end
  end

  describe '#restock' do
    it 'evaluates restock Redis script and returns true on success' do
      expect(redis).to receive(:eval).with(subject.send(:restock_redis_script), keys: keys, argv: quantities).and_return(1)
      expect(subject.send(:restock, keys, quantities)).to be true
    end

    it 'returns false on failure' do
      expect(redis).to receive(:eval).with(subject.send(:restock_redis_script), keys: keys, argv: quantities).and_return(0)
      expect(subject.send(:restock, keys, quantities)).to be false
    end
  end

  describe '#inventory_items' do
    it 'calls InventoryKeyQuantityBuilder with line_item_ids' do
      expect(SpreeCmCommissioner::RedisStock::InventoryKeyQuantityBuilder).to receive(:new).with(line_item_ids).and_return(inventory_builder)
      expect(inventory_builder).to receive(:call).and_return(inventory_items)
      subject.send(:inventory_items)
    end

    it 'returns the result of InventoryKeyQuantityBuilder#call' do
      expect(subject.send(:inventory_items)).to eq(inventory_items)
    end

    it 'memoizes the result' do
      expect(inventory_builder).to receive(:call).once.and_return(inventory_items)
      subject.send(:inventory_items)
      subject.send(:inventory_items)
      expect(subject.instance_variable_get(:@inventory_items)).to eq(inventory_items)
    end
  end

  describe '#extract_inventory_data' do
    it 'returns keys, quantities, and inventory_ids' do
      expect(subject.send(:extract_inventory_data)).to eq([keys, quantities, inventory_ids])
    end
  end

  describe '#unstock_redis_script' do
    it 'returns the unstock Lua script' do
      expect(subject.send(:unstock_redis_script)).to include('DECRBY')
      expect(subject.send(:unstock_redis_script)).to include('if current - tonumber(quantities[i]) < 0 then')
    end
  end

  describe '#restock_redis_script' do
    it 'returns the restock Lua script' do
      expect(subject.send(:restock_redis_script)).to include('INCRBY')
    end
  end

  describe '#schedule_sync_inventory' do
    it 'schedules InventoryItemSyncerJob with inventory_ids and quantities' do
      expect(SpreeCmCommissioner::InventoryItemSyncerJob).to receive(:perform_later).with(inventory_ids: inventory_ids, quantities: quantities)
      subject.send(:schedule_sync_inventory, inventory_ids, quantities)
    end
  end
end
