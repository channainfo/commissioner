require 'spec_helper'

RSpec.describe SpreeCmCommissioner::InventoryBooking do
  subject { described_class.new }
  let(:redis) { instance_double(Redis) }
  let(:redis_pool) { double('redis_pool') }
  let(:valid_params) do
    [
      { inventory_key: 'inventory:1', quantity: 2 },
      { inventory_key: 'inventory:2', quantity: 1 }
    ]
  end

  before do
    allow(SpreeCmCommissioner).to receive(:redis_pool).and_return(redis_pool)
    allow(redis_pool).to receive(:with).and_yield(redis)
  end

  describe '#book_inventories' do
    context 'with invalid parameters' do
      it 'raises error when params is not an array' do
        expect { subject.book_inventories('not_an_array') }
          .to raise_error('Inventory params must be an array')
      end

      it 'raises error when params is an empty array' do
        expect { subject.book_inventories([]) }
          .to raise_error('Inventory params cannot be blank')
      end
    end

    context 'with valid parameters' do
      it 'returns true and schedules sync when inventory can be reserved' do
        expect(redis).to receive(:eval).and_return(1)
        expect(SpreeCmCommissioner::InventoryItemSyncerJob)
          .to receive(:perform_later)
          .with(['1', '2'], [2, 1])

        result = subject.book_inventories(valid_params)
        expect(result).to be true
      end

      it 'returns false when inventory cannot be reserved' do
        expect(redis).to receive(:eval).and_return(0)
        expect(SpreeCmCommissioner::InventoryItemSyncerJob)
          .not_to receive(:perform_later)

        result = subject.book_inventories(valid_params)
        expect(result).to be false
      end
    end
  end

  describe '#can_supply_all?' do
    context 'with invalid parameters' do
      it 'raises error when params is not an array' do
        expect { subject.can_supply_all?('not_an_array') }
          .to raise_error('Inventory params must be an array')
      end
    end

    context 'with valid parameters' do
      it 'returns true when all inventory is available' do
        expect(redis).to receive(:eval).and_return(1)
        result = subject.can_supply_all?(valid_params)
        expect(result).to be true
      end

      it 'returns false when inventory is not available' do
        expect(redis).to receive(:eval).and_return(0)
        result = subject.can_supply_all?(valid_params)
        expect(result).to be false
      end
    end
  end

  describe 'private methods' do
    describe '#validate_params' do
      it 'returns params when valid' do
        expect(subject.send(:validate_params, valid_params)).to eq(valid_params)
      end
    end

    describe '#extract_inventory_data' do
      it 'correctly extracts keys, quantities, and ids' do
        keys, quantities, inventory_ids = subject.send(:extract_inventory_data, valid_params)
        expect(keys).to eq(['inventory:1', 'inventory:2'])
        expect(quantities).to eq([2, 1])
        expect(inventory_ids).to eq(['1', '2'])
      end
    end

    describe '#reserve_inventory' do
      it 'returns true when redis script returns positive value' do
        expect(redis).to receive(:eval).and_return(1)
        result = subject.send(:reserve_inventory, ['inventory:1'], [1])
        expect(result).to be true
      end

      it 'returns false when redis script returns zero' do
        expect(redis).to receive(:eval).and_return(0)
        result = subject.send(:reserve_inventory, ['inventory:1'], [1])
        expect(result).to be false
      end
    end

    describe '#inventory_available?' do
      it 'returns true when redis script returns positive value' do
        expect(redis).to receive(:eval).and_return(1)
        result = subject.send(:inventory_available?, ['inventory:1'], [1])
        expect(result).to be true
      end

      it 'returns false when redis script returns zero' do
        expect(redis).to receive(:eval).and_return(0)
        result = subject.send(:inventory_available?, ['inventory:1'], [1])
        expect(result).to be false
      end
    end
  end

  # Integration test with actual Redis behavior
  describe 'integration with redis', :redis do
    let(:real_redis) { Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379/0') }
    let(:redis_pool) { double('redis_pool') }

    before do
      allow(SpreeCmCommissioner).to receive(:redis_pool).and_return(redis_pool)
      allow(redis_pool).to receive(:with).and_yield(real_redis)
      real_redis.flushdb
    end

    it 'successfully books available inventory' do
      real_redis.set('inventory:1', 5)
      real_redis.set('inventory:2', 3)

      result = subject.book_inventories(valid_params)
      expect(result).to be true
      expect(real_redis.get('inventory:1')).to eq('3')
      expect(real_redis.get('inventory:2')).to eq('2')
    end

    it 'fails to book when inventory is insufficient' do
      real_redis.set('inventory:1', 1) # Less than required 2
      real_redis.set('inventory:2', 3)

      result = subject.book_inventories(valid_params)
      expect(result).to be false
      expect(real_redis.get('inventory:1')).to eq('1') # Unchanged
      expect(real_redis.get('inventory:2')).to eq('3') # Unchanged
    end
  end
end
