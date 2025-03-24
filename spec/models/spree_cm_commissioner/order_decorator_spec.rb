require 'spec_helper'

RSpec.describe SpreeCmCommissioner::OrderDecorator, type: :model do
  let(:order) { create(:order_with_line_items, line_items_count: 2) }
  let(:inventory_booking) { SpreeCmCommissioner::InventoryBooking.new }
  let(:inventory_params) do
    [
      { inventory_key: 'inventory:1', quantity: 2 },
      { inventory_key: 'inventory:2', quantity: 1 }
    ]
  end

  before do
    allow(SpreeCmCommissioner::InventoryBooking).to receive(:new).and_return(inventory_booking)
    allow(order).to receive(:inventory_params).and_return(inventory_params)
  end

  describe '#finalize!' do
    context 'when unstocking in Redis succeeds' do
      before do
        allow(inventory_booking).to receive(:book_inventories).with(inventory_params).and_return(true)
      end

      it 'unstocks inventory in Redis and calls super' do
        expect(order).to receive(:manifest_unstock_in_redis!)

        order.finalize!
      end
    end

    context 'when unstocking in Redis fails' do
      before do
        allow(inventory_booking).to receive(:book_inventories).with(inventory_params).and_return(false)
      end

      it 'raises an insufficient stock error' do
        expect { order.finalize! }.to raise_error(Spree.t(:insufficient_stock_lines_present))
      end
    end
  end

  describe '#insufficient_stock_lines' do
    context 'when stock is sufficient' do
      before do
        allow(inventory_booking).to receive(:can_supply_all?).with(inventory_params).and_return(true)
      end

      it 'returns an empty array' do
        expect(order.insufficient_stock_lines).to eq([])
      end
    end

    context 'when stock is insufficient' do
      before do
        allow(inventory_booking).to receive(:can_supply_all?).with(inventory_params).and_return(false)
      end

      it 'returns an array with a placeholder value' do
        expect(order.insufficient_stock_lines).to eq([1])
      end
    end
  end

  describe '#sufficient_stock_lines?' do
    it 'delegates to InventoryBooking#can_supply_all?' do
      expect(inventory_booking).to receive(:can_supply_all?).with(inventory_params).and_return(true)
      expect(order.sufficient_stock_lines?).to be true
    end
  end

  describe 'private methods' do
    describe '#inventory_params' do
      it 'maps line items to their inventory params' do
        # Assuming line_item.inventory_params returns a hash
        allow(order.line_items).to receive(:includes).and_return(order.line_items)
        expect(order.send(:inventory_params)).to be_a(Array)
        expect(order.send(:inventory_params).first).to have_key(:inventory_key)
        expect(order.send(:inventory_params).first).to have_key(:quantity)
      end
    end

    describe '#manifest_unstock_in_redis!' do
      context 'when unstock_inventory_in_redis returns false' do
        before do
          allow(order).to receive(:unstock_inventory_in_redis).and_return(false)
        end

        it 'raises an insufficient stock error' do
          expect { order.send(:manifest_unstock_in_redis!) }
            .to raise_error(Spree.t(:insufficient_stock_lines_present))
        end
      end

      context 'when unstock_inventory_in_redis returns true' do
        before do
          allow(order).to receive(:unstock_inventory_in_redis).and_return(true)
        end

        it 'does not raise an error' do
          expect { order.send(:manifest_unstock_in_redis!) }.not_to raise_error
        end
      end
    end

    describe '#unstock_inventory_in_redis' do
      it 'delegates to InventoryBooking#book_inventories' do
        expect(inventory_booking).to receive(:book_inventories).with(inventory_params).and_return(true)
        expect(order.send(:unstock_inventory_in_redis)).to be true
      end
    end
  end

  # Integration test with real Redis
  describe 'integration with Redis', :redis do
    let(:redis) { Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379/0') }
    let(:redis_pool) { double('redis_pool') }
    let(:inventory_booking) { SpreeCmCommissioner::InventoryBooking.new }

    before do
      # Use real InventoryBooking instead of mock
      allow(SpreeCmCommissioner).to receive(:redis_pool).and_return(redis_pool)
      allow(redis_pool).to receive(:with).and_yield(redis)

      allow(SpreeCmCommissioner::InventoryBooking).to receive(:new).and_return(inventory_booking)
      redis.flushdb
      # Set up initial inventory
      redis.set('inventory:1', 5)
      redis.set('inventory:2', 3)
    end

    describe '#finalize!' do
      it 'successfully unstocks inventory and finalizes the order' do
        allow(order).to receive(:super) # Stub super call
        order.finalize!
        expect(redis.get('inventory:1')).to eq('3')
        expect(redis.get('inventory:2')).to eq('2')
      end

      context 'when inventory is insufficient' do
        before do
          redis.set('inventory:1', 1) # Less than required 2
        end

        it 'raises an insufficient stock error' do
          expect { order.finalize! }.to raise_error(Spree.t(:insufficient_stock_lines_present))
          expect(redis.get('inventory:1')).to eq('1') # Unchanged
          expect(redis.get('inventory:2')).to eq('3') # Unchanged
        end
      end
    end
  end
end
