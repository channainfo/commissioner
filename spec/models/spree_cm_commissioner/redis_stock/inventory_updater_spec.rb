require 'spec_helper'

RSpec.describe SpreeCmCommissioner::RedisStock::InventoryUpdater do
  let(:line_items) { [double('line_item')] }
  let(:inventory_updater) { described_class.new(line_items) }
  let(:inventory_data) do
    [
      { inventory_key: 'inventory:1', quantity: 2, inventory_item_id: 1 },
      { inventory_key: 'inventory:2', quantity: 3, inventory_item_id: 2 }
    ]
  end
  let(:keys) { ['inventory:1', 'inventory:2'] }
  let(:quantities) { [2, 3] }
  let(:inventory_ids) { [1, 2] }
  let(:redis) { instance_double(Redis) }
  let(:redis_pool) { double('redis_pool') }

  before do
    allow(SpreeCmCommissioner).to receive(:redis_pool).and_return(redis_pool)
    allow(redis_pool).to receive(:with).and_yield(redis)
  end

  describe '#initialize' do
    it 'sets line_items' do
      expect(inventory_updater.line_items).to eq(line_items)
    end

    it 'defaults to empty array if no line_items provided' do
      updater = described_class.new
      expect(updater.line_items).to eq([])
    end
  end

  describe '#unstock!' do
    before do
      allow(inventory_updater).to receive(:inventory_items).and_return(inventory_data)
    end

    context 'when unstock succeeds' do
      it 'unstocks and schedules sync job' do
        expect(inventory_updater).to receive(:extract_inventory_data).and_return([keys, quantities, inventory_ids])
        expect(inventory_updater).to receive(:unstock).with(keys, quantities).and_return(true)
        expect(inventory_updater).to receive(:schedule_sync_inventory).with(inventory_ids)
        expect { inventory_updater.unstock! }.not_to raise_error
      end
    end

    context 'when unstock fails' do
      it 'raises UnableToUnstock with translation message' do
        allow(Spree).to receive(:t).with(:insufficient_stock_lines_present).and_return('Insufficient stock')
        expect(inventory_updater).to receive(:extract_inventory_data).and_return([keys, quantities, inventory_ids])
        expect(inventory_updater).to receive(:unstock).with(keys, quantities).and_return(false)
        expect { inventory_updater.unstock! }.to raise_error(described_class::UnableToUnstock, 'Insufficient stock')
      end
    end
  end

  describe '#restock!' do
    before do
      allow(inventory_updater).to receive(:inventory_items).and_return(inventory_data)
    end

    context 'when restock succeeds' do
      it 'restocks and schedules sync job' do
        expect(inventory_updater).to receive(:extract_inventory_data).and_return([keys, quantities, inventory_ids])
        expect(inventory_updater).to receive(:restock).with(keys, quantities).and_return(true)
        expect(inventory_updater).to receive(:schedule_sync_inventory).with(inventory_ids)
        expect { inventory_updater.restock! }.not_to raise_error
      end
    end

    context 'when restock fails' do
      it 'raises UnableToRestock' do
        expect(inventory_updater).to receive(:extract_inventory_data).and_return([keys, quantities, inventory_ids])
        expect(inventory_updater).to receive(:restock).with(keys, quantities).and_return(false)
        expect { inventory_updater.restock! }.to raise_error(described_class::UnableToRestock)
      end
    end
  end

  describe '#unstock' do
    let(:script) { inventory_updater.send(:unstock_redis_script) }

    it 'evaluates unstock Lua script and returns true when result is positive' do
      expect(redis).to receive(:eval).with(script, keys: keys, argv: quantities).and_return(1)
      expect(inventory_updater.send(:unstock, keys, quantities)).to be true
    end

    it 'returns false when script returns 0' do
      expect(redis).to receive(:eval).with(script, keys: keys, argv: quantities).and_return(0)
      expect(inventory_updater.send(:unstock, keys, quantities)).to be false
    end
  end

  describe '#restock' do
    let(:script) { inventory_updater.send(:restock_redis_script) }

    it 'evaluates restock Lua script and returns true when result is positive' do
      expect(redis).to receive(:eval).with(script, keys: keys, argv: quantities).and_return(1)
      expect(inventory_updater.send(:restock, keys, quantities)).to be true
    end

    it 'returns false when script returns 0' do
      expect(redis).to receive(:eval).with(script, keys: keys, argv: quantities).and_return(0)
      expect(inventory_updater.send(:restock, keys, quantities)).to be false
    end
  end

  describe '#inventory_items' do
    it 'calls InventoryKeyQuantityBuilder and caches result' do
      builder = double('builder')
      expect(SpreeCmCommissioner::RedisStock::InventoryKeyQuantityBuilder)
        .to receive(:new).with(line_items).and_return(builder)
      expect(builder).to receive(:call).and_return(inventory_data)
      expect(inventory_updater.send(:inventory_items)).to eq(inventory_data)
      expect(inventory_updater.send(:inventory_items)).to eq(inventory_data) # Cached
    end
  end

  describe '#extract_inventory_data' do
    before do
      allow(inventory_updater).to receive(:inventory_items).and_return(inventory_data)
    end

    it 'extracts keys, quantities, and inventory_ids' do
      expect(inventory_updater.send(:extract_inventory_data)).to eq([keys, quantities, inventory_ids])
    end
  end

  describe '#unstock_redis_script' do
    it 'returns the correct Lua script' do
      script = inventory_updater.send(:unstock_redis_script)
      expect(script).to include('local keys = KEYS')
      expect(script).to include('local quantities = ARGV')
      expect(script).to include('redis.call(\'DECRBY\'')
      expect(script).to include('return 0')
      expect(script).to include('return 1')
    end
  end

  describe '#restock_redis_script' do
    it 'returns the correct Lua script' do
      script = inventory_updater.send(:restock_redis_script)
      expect(script).to include('local keys = KEYS')
      expect(script).to include('local quantities = ARGV')
      expect(script).to include('redis.call(\'INCRBY\'')
      expect(script).to include('return 1')
    end
  end

  describe '#schedule_sync_inventory' do
    it 'enqueues InventoryItemSyncerJob with inventory_ids' do
      expect(SpreeCmCommissioner::InventoryItemSyncerJob).to receive(:perform_later).with(inventory_ids)
      inventory_updater.send(:schedule_sync_inventory, inventory_ids)
    end
  end

  describe 'integration with redis', :redis do
    let(:real_redis) { Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379/0') }
    let(:redis_pool) { double('redis_pool') }
    let(:builder) { double('builder') }

    before do
      real_redis.flushdb
      allow(SpreeCmCommissioner).to receive(:redis_pool).and_return(redis_pool)
      allow(redis_pool).to receive(:with).and_yield(real_redis)
      allow(SpreeCmCommissioner::RedisStock::InventoryKeyQuantityBuilder)
        .to receive(:new).with(line_items).and_return(builder)
      allow(builder).to receive(:call).and_return(inventory_data)
      allow(inventory_updater).to receive(:schedule_sync_inventory) # Prevent actual job scheduling
    end

    after do
      real_redis.flushdb
    end

    describe '#unstock!' do
      context 'when sufficient inventory exists' do
        before do
          real_redis.set('inventory:1', 5)
          real_redis.set('inventory:2', 5)
        end

        it 'unstocks successfully and updates Redis' do
          expect { inventory_updater.unstock! }.not_to raise_error
          expect(real_redis.get('inventory:1')).to eq('3') # 5 - 2
          expect(real_redis.get('inventory:2')).to eq('2') # 5 - 3
        end
      end

      context 'when insufficient inventory exists' do
        before do
          real_redis.set('inventory:1', 1) # Less than required 2
          real_redis.set('inventory:2', 5)
        end

        it 'raises UnableToUnstock' do
          allow(Spree).to receive(:t).with(:insufficient_stock_lines_present).and_return('Insufficient stock')
          expect { inventory_updater.unstock! }.to raise_error(described_class::UnableToUnstock, 'Insufficient stock')
          expect(real_redis.get('inventory:1')).to eq('1') # Unchanged
          expect(real_redis.get('inventory:2')).to eq('5') # Unchanged
        end
      end
    end

    describe '#restock!' do
      context 'when restocking' do
        before do
          real_redis.set('inventory:1', 5)
          real_redis.set('inventory:2', 5)
        end

        it 'restocks successfully and updates Redis' do
          expect { inventory_updater.restock! }.not_to raise_error
          expect(real_redis.get('inventory:1')).to eq('7') # 5 + 2
          expect(real_redis.get('inventory:2')).to eq('8') # 5 + 3
        end
      end

      context 'when keys do not exist' do
        it 'creates new keys with correct quantities' do
          expect { inventory_updater.restock! }.not_to raise_error
          expect(real_redis.get('inventory:1')).to eq('2')
          expect(real_redis.get('inventory:2')).to eq('3')
        end
      end
    end
  end
end
