require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Stock::InventoryItemsAdjuster, type: :interactor do
  describe '.call' do
    let(:variant) { create(:variant) }
    let(:quantity) { 10 }
    let(:today) { Time.zone.today }
    let(:inventory_item1) { create(:cm_inventory_item, variant: variant, max_capacity: 100, quantity_available: 50, inventory_date: today) }
    let(:inventory_item2) { create(:cm_inventory_item, variant: variant, max_capacity: 200, quantity_available: 150, inventory_date: today + 1.day) }
    let(:inactive_inventory_item) { create(:cm_inventory_item, variant: variant, max_capacity: 300, quantity_available: 250, inventory_date: today - 1.day) }
    subject(:interactor) { described_class.call(variant: variant, quantity: quantity) }

    before do
      # Create active and inactive inventory items
      inventory_item1
      inventory_item2
      inactive_inventory_item

      # Debug: Log when adjust_quantity! is called
      allow_any_instance_of(SpreeCmCommissioner::InventoryItem).to receive(:adjust_quantity!).and_wrap_original do |method, qty|
        Rails.logger.debug "adjust_quantity! called on item #{method.receiver.id} with quantity #{qty}"
        method.call(qty)
      end
    end

    it 'calls adjust_quantity! on each active inventory item' do
      active_items = variant.inventory_items.active.to_a
      expect(active_items).to include(inventory_item1, inventory_item2), "Active scope should include inventory_item1 and inventory_item2"
      expect(active_items).not_to include(inactive_inventory_item), "Active scope should exclude inactive_inventory_item"

      interactor

      # Verify side effects to confirm method execution
      expect(inventory_item1.reload.quantity_available).to eq(60), "inventory_item1 quantity_available should increase by 10"
      expect(inventory_item2.reload.quantity_available).to eq(160), "inventory_item2 quantity_available should increase by 10"
      expect(inactive_inventory_item.reload.quantity_available).to eq(250), "inactive_inventory_item quantity_available should not change"
    end

    it 'processes only active inventory items' do
      expect(variant.inventory_items).to receive(:active).and_call_original
      interactor
    end

    it 'succeeds when inventory items are updated' do
      expect(interactor).to be_success
    end

    context 'when no active inventory items exist' do
      before do
        variant.inventory_items.active.destroy_all
      end

      it 'does not call adjust_quantity! on any inventory items' do
        expect_any_instance_of(SpreeCmCommissioner::InventoryItem).not_to receive(:adjust_quantity!)
        interactor
      end

      it 'still succeeds' do
        expect(interactor).to be_success
      end
    end
  end
end
