require 'spec_helper'

RSpec.describe SpreeCmCommissioner::InventoryItemSyncer do
  describe '#call' do
    let(:inventory_ids) { [1, 2] }
    let(:context) { Interactor::Context.new(inventory_ids: inventory_ids) }
    let(:redis_pool) { double('RedisPool') }
    let(:redis) { double('Redis') }
    let(:inventory_item1) { create(:cm_inventory_item, id: 1) }
    let(:inventory_item2) { create(:cm_inventory_item, id: 2) }

    before do
      allow(SpreeCmCommissioner).to receive(:redis_pool).and_return(redis_pool)
      allow(redis_pool).to receive(:with).and_yield(redis)
      allow(described_class).to receive(:new).and_return(subject)
      allow(subject).to receive(:context).and_return(context)
    end

    it 'calls sync_inventories with redis connection' do
      expect(subject).to receive(:sync_inventories).with(redis)
      subject.call
    end
  end

  describe '#sync_inventories' do
    let(:redis) { double('Redis') }
    let(:inventory_item1) { create(:cm_inventory_item, id: 1) }
    let(:inventory_item2) { create(:cm_inventory_item, id: 2) }
    let(:inventory_ids) { [1, 2] }
    let(:context) { Interactor::Context.new(inventory_ids: inventory_ids) }

    before do
      allow(subject).to receive(:context).and_return(context)
      allow(SpreeCmCommissioner::InventoryItem).to receive(:where)
        .with(id: inventory_ids)
        .and_return([inventory_item1, inventory_item2])
    end

    it 'updates quantity_available for each inventory item from redis' do
      allow(redis).to receive(:get).with('inventory:1').and_return('10')
      allow(redis).to receive(:get).with('inventory:2').and_return('20')

      expect(inventory_item1).to receive(:update!).with(quantity_available: '10')
      expect(inventory_item2).to receive(:update!).with(quantity_available: '20')

      subject.send(:sync_inventories, redis)
    end
  end

  describe '#inventory_items' do
    let(:inventory_ids) { [1, 2] }
    let(:context) { Interactor::Context.new(inventory_ids: inventory_ids) }

    before do
      allow(subject).to receive(:context).and_return(context)
    end

    it 'returns inventory items matching the context inventory_ids' do
      expect(SpreeCmCommissioner::InventoryItem).to receive(:where).with(id: inventory_ids)
      subject.send(:inventory_items)
    end
  end

  # New spec with real Redis
  describe '#call with real Redis', redis: true do
    let(:inventory_ids) { [1, 2] }
    let(:context) { Interactor::Context.new(inventory_ids: inventory_ids) }
    let(:inventory_item1) { create(:cm_inventory_item, id: 1, quantity_available: 0) }
    let(:inventory_item2) { create(:cm_inventory_item, id: 2, quantity_available: 0) }
    let(:real_redis) { Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379/1') }

    before do
      # Set up Redis with test data
      real_redis.set('inventory:1', '15')
      real_redis.set('inventory:2', '25')

      # Mock the redis_pool to yield the real Redis instance
      allow(SpreeCmCommissioner).to receive(:redis_pool).and_return(real_redis)
      allow(real_redis).to receive(:with).and_yield(real_redis)

      # Ensure inventory items are loaded
      allow(SpreeCmCommissioner::InventoryItem).to receive(:where)
        .with(id: inventory_ids)
        .and_return([inventory_item1, inventory_item2])

      allow(subject).to receive(:context).and_return(context)
    end

    after do
      # Clean up Redis keys to avoid test pollution
      real_redis.del('inventory:1', 'inventory:2')
      real_redis.close
    end

    it 'updates inventory items with quantities from real Redis' do
      subject.call

      expect(inventory_item1.reload.quantity_available).to eq(15)
      expect(inventory_item2.reload.quantity_available).to eq(25)
    end
  end
end
