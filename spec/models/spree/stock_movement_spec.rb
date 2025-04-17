require 'spec_helper'

RSpec.describe Spree::StockMovement, type: :model do
  let(:variant) { create(:variant) }
  let(:stock_item) { create(:stock_item, variant: variant) }
  let(:stock_movement) { build(:stock_movement, stock_item: stock_item, quantity: 5) }

  before do
    allow(stock_movement).to receive(:stock_item).and_return(stock_item)
    allow(stock_movement).to receive(:variant).and_return(variant)
  end

  describe 'after_create :adjust_inventory_items' do
    it 'calls adjust_inventory_items if should_track_inventory? is true' do
      allow(stock_item).to receive(:should_track_inventory?).and_return(true)

      expect(stock_movement).to receive(:adjust_inventory_items)
      stock_movement.run_callbacks(:create)
    end

    it 'does not call adjust_inventory_items if should_track_inventory? is false' do
      allow(stock_item).to receive(:should_track_inventory?).and_return(false)

      expect(stock_movement).not_to receive(:adjust_inventory_items)
      stock_movement.run_callbacks(:create)
    end
  end

  describe '#adjust_inventory_items' do
    context 'when variant is not permanent stock and no default inventory item exists' do
      it 'creates default non-permanent inventory item' do
        allow(variant).to receive(:permanent_stock?).and_return(false)
        allow(variant).to receive(:default_inventory_item_exist?).and_return(false)

        expect(variant).to receive(:create_default_non_permanent_inventory_item!)
        stock_movement.send(:adjust_inventory_items)
      end
    end

    context 'when variant is permanent stock or default inventory item exists' do
      it 'adjusts existing inventory items' do
        allow(variant).to receive(:permanent_stock?).and_return(false)
        allow(variant).to receive(:default_inventory_item_exist?).and_return(true)

        expect(stock_movement).to receive(:adjust_existing_inventory_items!)
        stock_movement.send(:adjust_inventory_items)
      end
    end
  end

  describe '#adjust_existing_inventory_items!' do
    it 'adjusts quantity on each active inventory item' do
      inventory_item1 = instance_double('InventoryItem')
      inventory_item2 = instance_double('InventoryItem')

      allow(variant).to receive_message_chain(:inventory_items, :active, :find_each)
        .and_yield(inventory_item1).and_yield(inventory_item2)

      expect(inventory_item1).to receive(:adjust_quantity!).with(stock_movement.quantity)
      expect(inventory_item2).to receive(:adjust_quantity!).with(stock_movement.quantity)

      stock_movement.send(:adjust_existing_inventory_items!)
    end
  end
end
