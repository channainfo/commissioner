require 'spec_helper'

RSpec.describe SpreeCmCommissioner::OrderDecorator, type: :model do
  let(:order) { create(:order_with_line_items, line_items_count: 2) }
  let(:line_items) { order.line_items }
  let(:line_item_ids) { line_items.map(&:id) }
  let(:inventory_updater) { instance_double(SpreeCmCommissioner::RedisStock::InventoryUpdater) }

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
