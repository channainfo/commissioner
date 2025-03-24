require 'spec_helper'

RSpec.describe SpreeCmCommissioner::OrderDecorator, type: :model do
  let(:order) { create(:order_with_line_items, line_items_count: 2) }
  let(:line_items) { order.line_items }
  let(:line_item_ids) { line_items.map(&:id) }
  let(:inventory_checker) { instance_double(SpreeCmCommissioner::RedisStock::InventoryChecker) }
  let(:inventory_updater) { instance_double(SpreeCmCommissioner::RedisStock::InventoryUpdater) }

  describe '#ensure_line_items_are_in_stock' do
    context 'when sufficient stock is available' do
      before do
        allow(order).to receive(:sufficient_stock_lines?).and_return(true)
      end

      it 'returns true and does not restart checkout flow' do
        expect(order).not_to receive(:restart_checkout_flow)
        expect(order.ensure_line_items_are_in_stock).to eq(true)
      end
    end

    context 'when insufficient stock is available' do
      before do
        allow(order).to receive(:sufficient_stock_lines?).and_return(false)
        allow(order).to receive(:restart_checkout_flow)
        allow(order.errors).to receive(:add)
      end

      it 'restarts checkout flow, adds error, and returns false' do
        expect(order).to receive(:restart_checkout_flow)
        expect(order.errors).to receive(:add).with(:base, Spree.t(:insufficient_stock_lines_present))
        expect(order.ensure_line_items_are_in_stock).to eq(false)
      end
    end
  end

  describe '#sufficient_stock_lines?' do
    before do
      allow(SpreeCmCommissioner::RedisStock::InventoryChecker).to receive(:new).with(line_item_ids).and_return(inventory_checker)
    end

    it 'calls InventoryChecker#can_supply_all?' do
      expect(inventory_checker).to receive(:can_supply_all?).and_return(true)
      expect(order.send(:sufficient_stock_lines?)).to eq(true)
    end
  end

  describe '#unstock_inventory_in_redis!' do
    before do
      allow(SpreeCmCommissioner::RedisStock::InventoryUpdater).to receive(:new).with(line_item_ids).and_return(inventory_updater)
    end

    it 'calls InventoryUpdater#unstock!' do
      expect(inventory_updater).to receive(:unstock!)
      order.send(:unstock_inventory_in_redis!)
    end
  end

  describe '#restock_inventory_in_redis!' do
    before do
      allow(SpreeCmCommissioner::RedisStock::InventoryUpdater).to receive(:new).with(line_item_ids).and_return(inventory_updater)
    end

    it 'calls InventoryUpdater#restock!' do
      expect(inventory_updater).to receive(:restock!)
      order.send(:restock_inventory_in_redis!)
    end
  end
end
