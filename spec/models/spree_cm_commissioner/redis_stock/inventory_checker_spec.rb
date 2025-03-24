require 'spec_helper'

RSpec.describe SpreeCmCommissioner::RedisStock::InventoryChecker do
  let(:line_items) { [double('line_item')] }
  let(:inventory_checker) { described_class.new(line_items) }
  let(:inventory_data) do
    [
      { inventory_key: 'inventory:1', quantity: 5 },
      { inventory_key: 'inventory:2', quantity: 3 }
    ]
  end
  let(:keys) { ['inventory:1', 'inventory:2'] }
  let(:quantities) { [5, 3] }
  let(:redis) { instance_double(Redis) }
  let(:redis_pool) { double('redis_pool') }

  before do
    allow(SpreeCmCommissioner).to receive(:redis_pool).and_return(redis_pool)
    allow(redis_pool).to receive(:with).and_yield(redis)
  end

  describe '#initialize' do
    it 'sets line_items' do
      expect(inventory_checker.line_items).to eq(line_items)
    end
  end

  describe '#can_supply_all?' do
    let(:inventory_key_quantity_builder) { double('inventory_key_quantity_builder') }

    before do
      allow(SpreeCmCommissioner::RedisStock::InventoryKeyQuantityBuilder)
        .to receive(:new).with(line_items).and_return(inventory_key_quantity_builder)
      allow(inventory_key_quantity_builder).to receive(:call).and_return(inventory_data)
    end

    context 'when inventory is available' do
      it 'returns true' do
        expect(inventory_checker).to receive(:extract_inventory_data).with(inventory_data).and_return([keys, quantities])
        expect(inventory_checker).to receive(:inventory_available?).with(keys, quantities).and_return(true)
        expect(inventory_checker.can_supply_all?).to be true
      end
    end

    context 'when inventory is not available' do
      it 'returns false' do
        expect(inventory_checker).to receive(:extract_inventory_data).with(inventory_data).and_return([keys, quantities])
        expect(inventory_checker).to receive(:inventory_available?).with(keys, quantities).and_return(false)
        expect(inventory_checker.can_supply_all?).to be false
      end
    end

    context 'with custom line items' do
      let(:custom_line_items) { [double('custom_line_item')] }
      let(:custom_inventory_data) { [{ inventory_key: 'inventory:3', quantity: 2 }] }

      it 'uses provided line items' do
        allow(SpreeCmCommissioner::RedisStock::InventoryKeyQuantityBuilder)
          .to receive(:new).with(custom_line_items).and_return(inventory_key_quantity_builder)
        allow(inventory_key_quantity_builder).to receive(:call).and_return(custom_inventory_data)
        expect(inventory_checker).to receive(:extract_inventory_data).with(custom_inventory_data).and_return([['inventory:3'], [2]])
        expect(inventory_checker).to receive(:inventory_available?).with(['inventory:3'], [2]).and_return(true)
        expect(inventory_checker.can_supply_all?(custom_line_items)).to be true
      end
    end
  end

  describe '#inventory_items' do
    it 'calls InventoryKeyQuantityBuilder with line_items' do
      inventory_key_quantity_builder = double('inventory_key_quantity_builder')
      expect(SpreeCmCommissioner::RedisStock::InventoryKeyQuantityBuilder)
        .to receive(:new).with(line_items).and_return(inventory_key_quantity_builder)
      expect(inventory_key_quantity_builder).to receive(:call).and_return(inventory_data)
      expect(inventory_checker.send(:inventory_items)).to eq(inventory_data)
    end
  end

  describe '#extract_inventory_data' do
    it 'extracts keys and quantities from inventory data' do
      result = inventory_checker.send(:extract_inventory_data, inventory_data)
      expect(result).to eq([keys, quantities])
    end
  end

  describe '#inventory_available?' do
    let(:script) { inventory_checker.send(:can_supply_script) }

    it 'evaluates the Lua script with keys and quantities' do
      expect(redis).to receive(:eval).with(script, keys: keys, argv: quantities).and_return(1)
      expect(inventory_checker.send(:inventory_available?, keys, quantities)).to be true
    end

    it 'returns false when script returns 0' do
      expect(redis).to receive(:eval).with(script, keys: keys, argv: quantities).and_return(0)
      expect(inventory_checker.send(:inventory_available?, keys, quantities)).to be false
    end
  end

  describe '#can_supply_script' do
    it 'returns the correct Lua script' do
      script = inventory_checker.send(:can_supply_script)
      expect(script).to include('local keys = KEYS')
      expect(script).to include('local quantities = ARGV')
      expect(script).to include('return 1 -- All inventories are available')
      expect(script).to include('return 0 -- Not enough inventory available')
    end
  end

  describe 'integration with redis', :redis do
    let(:real_redis) { Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379/0') }
    let(:redis_pool) { double('redis_pool') }
    let(:inventory_key_quantity_builder) { double('inventory_key_quantity_builder') }

    before do
      # Clear Redis before each test to ensure a clean state
      real_redis.flushdb
      allow(SpreeCmCommissioner).to receive(:redis_pool).and_return(redis_pool)
      allow(redis_pool).to receive(:with).and_yield(real_redis)
      allow(SpreeCmCommissioner::RedisStock::InventoryKeyQuantityBuilder)
        .to receive(:new).with(line_items).and_return(inventory_key_quantity_builder)
      allow(inventory_key_quantity_builder).to receive(:call).and_return(inventory_data)
    end

    after do
      # Clean up Redis after each test
      real_redis.flushdb
    end

    context 'when inventory is sufficient' do
      before do
        # Set up Redis with sufficient inventory
        real_redis.set('inventory:1', 10)
        real_redis.set('inventory:2', 5)
      end

      it 'returns true' do
        expect(inventory_checker.can_supply_all?).to be true
      end
    end

    context 'when inventory is insufficient' do
      before do
        # Set up Redis with insufficient inventory
        real_redis.set('inventory:1', 2) # Less than required 5
        real_redis.set('inventory:2', 5)
      end

      it 'returns false' do
        expect(inventory_checker.can_supply_all?).to be false
      end
    end

    context 'when inventory key does not exist' do
      before do
        # Only set one key, leaving 'inventory:2' unset (treated as 0)
        real_redis.set('inventory:1', 10)
      end

      it 'returns false' do
        expect(inventory_checker.can_supply_all?).to be false
      end
    end
  end
end
