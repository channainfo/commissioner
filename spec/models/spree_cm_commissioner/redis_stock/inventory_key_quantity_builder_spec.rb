require 'spec_helper'

RSpec.describe SpreeCmCommissioner::RedisStock::InventoryKeyQuantityBuilder do
  let(:redis) { double('Redis') }
  let(:redis_pool) { double('RedisPool') }
  let(:real_redis) { Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379/1') }
  let(:line_item_ids) { [1, 2] }
  let(:variant1) { create(:variant) }
  let(:variant2) { create(:variant) }
  let(:inventory_item1) { create(:cm_inventory_item, variant: variant1, quantity_available: 5, inventory_date: Date.today) }
  let(:inventory_item2) { create(:cm_inventory_item, variant: variant2, quantity_available: 3, inventory_date: Date.today + 1) }
  let(:line_item1) { create(:line_item, id: 1, variant: variant1, quantity: 2) }
  let(:line_item2) { create(:line_item, id: 2, variant: variant2, quantity: 1) }
  let(:line_items) { [line_item1, line_item2] }

  subject { described_class.new(line_item_ids) }

  before do
    allow(Spree::LineItem).to receive(:where).with(id: line_item_ids).and_return(line_items)
    allow(line_items).to receive(:includes).with(variant: [:product, :active_inventory_items]).and_return(line_items)
    allow(SpreeCmCommissioner).to receive(:redis_pool).and_return(redis_pool)
    allow(redis_pool).to receive(:with).and_yield(redis)
  end

  describe '#initialize' do
    it 'sets line_items based on provided line_item_ids' do
      expect(subject.line_items).to eq(line_items)
    end
  end

  describe '#call' do
    let(:keys1) { ["inventory:#{inventory_item1.id}"] }
    let(:keys2) { ["inventory:#{inventory_item2.id}"] }

    before do
      allow(subject).to receive(:inventory_items_for).with(line_item1).and_return([inventory_item1])
      allow(subject).to receive(:inventory_items_for).with(line_item2).and_return([inventory_item2])
      allow(redis).to receive(:mget).with(*keys1).and_return(['5'])
      allow(redis).to receive(:mget).with(*keys2).and_return(['3'])
    end

    it 'returns formatted inventory data for each line item' do
      expected_result = [
        {
          inventory_key: "inventory:#{inventory_item1.id}",
          purchase_quantity: 2,
          quantity_available: 5,
          inventory_item_id: inventory_item1.id
        },
        {
          inventory_key: "inventory:#{inventory_item2.id}",
          purchase_quantity: 1,
          quantity_available: 3,
          inventory_item_id: inventory_item2.id
        }
      ]

      expect(subject.call).to eq(expected_result)
    end

    context 'when redis returns nil for some keys' do
      before do
        allow(redis).to receive(:mget).with(*keys1).and_return([nil])
        allow(redis).to receive(:set).with("inventory:#{inventory_item1.id}", inventory_item1.quantity_available, ex: inventory_item1.redis_expired_in)
      end

      it 'caches missing inventory and uses quantity_available from inventory_item' do
        result = subject.call
        expect(result[0][:quantity_available]).to eq(inventory_item1.quantity_available)
        expect(redis).to have_received(:set).with("inventory:#{inventory_item1.id}", inventory_item1.quantity_available, ex: inventory_item1.redis_expired_in)
      end
    end

    context 'with real Redis' do
      before do
        # Override redis_pool to use real_redis
        allow(SpreeCmCommissioner).to receive(:redis_pool).and_return(real_redis)
        allow(subject).to receive(:inventory_items_for).with(line_item1).and_return([inventory_item1])
        allow(subject).to receive(:inventory_items_for).with(line_item2).and_return([inventory_item2])
        # Pre-set some inventory in Redis
        real_redis.set("inventory:#{inventory_item2.id}", 3, ex: inventory_item2.redis_expired_in)
      end

      after do
        # Clean up Redis keys after each test
        real_redis.del("inventory:#{inventory_item1.id}", "inventory:#{inventory_item2.id}")
      end

      it 'fetches inventory from Redis and caches missing keys' do
        expected_result = [
          {
            inventory_key: "inventory:#{inventory_item1.id}",
            purchase_quantity: 2,
            quantity_available: 5, # Cached from inventory_item1.quantity_available
            inventory_item_id: inventory_item1.id
          },
          {
            inventory_key: "inventory:#{inventory_item2.id}",
            purchase_quantity: 1,
            quantity_available: 3, # Fetched from Redis
            inventory_item_id: inventory_item2.id
          }
        ]

        result = subject.call
        expect(result).to match_array(expected_result)

        # Verify that inventory_item1 was cached in Redis
        cached_value = real_redis.get("inventory:#{inventory_item1.id}")
        expect(cached_value).to eq('5')
      end
    end
  end

  describe '#cache_inventory' do
    let(:key) { "inventory:#{inventory_item1.id}" }
    let(:count_in_redis) { '5' }

    context 'when count_in_redis is present' do
      it 'returns the count as an integer' do
        expect(subject.send(:cache_inventory, key, inventory_item1, count_in_redis)).to eq(5)
      end
    end

    context 'when count_in_redis is nil' do
      let(:count_in_redis) { nil }

      before do
        allow(redis).to receive(:set).with(key, inventory_item1.quantity_available, ex: inventory_item1.redis_expired_in)
      end

      it 'sets the inventory in redis and returns the quantity_available' do
        result = subject.send(:cache_inventory, key, inventory_item1, count_in_redis)
        expect(result).to eq(inventory_item1.quantity_available)
        expect(redis).to have_received(:set).with(key, inventory_item1.quantity_available, ex: inventory_item1.redis_expired_in)
      end
    end

    context 'with real Redis', redis: true do
      let(:count_in_redis) { nil }

      after do
        # Clean up Redis key after each test
        real_redis.del(key)
      end

      it 'sets the inventory in Redis and returns the quantity_available' do
        allow(SpreeCmCommissioner).to receive(:redis_pool).and_return(real_redis)
        result = subject.send(:cache_inventory, key, inventory_item1, count_in_redis)
        expect(result).to eq(inventory_item1.quantity_available)

        # Verify the key was set in Redis
        cached_value = real_redis.get(key)
        expect(cached_value).to eq(inventory_item1.quantity_available.to_s)

        # Verify the expiration was set
        ttl = real_redis.ttl(key)
        expect(ttl).to be <= inventory_item1.redis_expired_in
        expect(ttl).to be > 0
      end
    end
  end

  describe '#inventory_items_for' do
    let(:line_item) { line_item1 }
    let(:inventory_items) { [inventory_item1] }

    before do
      allow(line_item.variant).to receive(:active_inventory_items).and_return(inventory_items)
    end

    context 'when line_item is not permanent_stock' do
      before do
        allow(line_item).to receive(:permanent_stock?).and_return(false)
      end

      it 'returns all active inventory items' do
        expect(subject.send(:inventory_items_for, line_item)).to eq(inventory_items)
      end
    end

    context 'when line_item is permanent_stock' do
      let(:date_range) { Date.today..Date.today + 1 }
      let(:inventory_item_outside_range) { create(:cm_inventory_item, variant: variant1, inventory_date: Date.today - 1) }

      before do
        allow(line_item).to receive(:permanent_stock?).and_return(true)
        allow(line_item).to receive(:date_range).and_return(date_range)
        allow(inventory_item1).to receive(:inventory_date).and_return(Date.today)
      end

      it 'filters inventory items within the date range' do
        expect(subject.send(:inventory_items_for, line_item)).to eq([inventory_item1])
      end
    end
  end
end
