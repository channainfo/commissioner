require 'spec_helper'

RSpec.describe SpreeCmCommissioner::InventoryItemSyncer, type: :interactor do
  describe '.call' do
    let(:inventory_item1) { create(:cm_inventory_item, quantity_available: 10) }
    let(:inventory_item2) { create(:cm_inventory_item, quantity_available: 5) }
    let(:inventory_ids) { [inventory_item1.id, inventory_item2.id] }
    let(:quantities) { [3, 3] }
    let(:context) { Interactor::Context.new(inventory_ids: inventory_ids, quantities: quantities) }

    subject { described_class.call(context) }

    before do
      allow(context).to receive(:inventory_ids).and_return(inventory_ids)
      allow(context).to receive(:quantities).and_return(quantities)
    end

    it 'fetches inventory items and updates their quantities' do
      expect(SpreeCmCommissioner::InventoryItem).to receive(:where).with(id: inventory_ids).and_return([inventory_item1, inventory_item2])

      subject

      expect(inventory_item1.reload.quantity_available).to eq(7)
      expect(inventory_item2.reload.quantity_available).to eq(2)
    end

    context 'when inventory items are not found' do
      let(:inventory_ids) { [999] }  # Non-existent ID

      it 'handles empty collection gracefully' do
        expect(SpreeCmCommissioner::InventoryItem).to receive(:where).with(id: inventory_ids).and_return([])
        expect { subject }.not_to raise_error
      end
    end
  end

  describe '#fetch_inventory_items' do
    let(:inventory_ids) { [1, 2, 3] }
    let(:context) { Interactor::Context.new(inventory_ids: inventory_ids) }
    let(:instance) { described_class.new(context) }

    it 'queries InventoryItem with given ids' do
      expect(SpreeCmCommissioner::InventoryItem).to receive(:where).with(id: inventory_ids)
      instance.send(:fetch_inventory_items)
    end
  end

  describe '#manifest_unstock' do
    let(:inventory_item) { create(:cm_inventory_item, quantity_available: 10) }
    let(:quantity) { 4 }
    let(:context) { Interactor::Context.new(quantity: quantity) }
    let(:instance) { described_class.new(context) }

    it 'updates inventory item quantity_available' do
      expect(inventory_item).to receive(:update!).with(quantity_available: 6)
      instance.send(:manifest_unstock, inventory_item, quantity)
    end

    it 'decreases quantity_available by the specified amount' do
      instance.send(:manifest_unstock, inventory_item, quantity)
      expect(inventory_item.reload.quantity_available).to eq(6)
    end
  end
end
