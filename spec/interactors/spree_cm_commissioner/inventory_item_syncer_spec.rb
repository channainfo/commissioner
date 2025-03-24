# spec/spree_cm_commissioner/inventory_item_syncer_spec.rb
require 'spec_helper'

RSpec.describe SpreeCmCommissioner::InventoryItemSyncer, type: :interactor do
  describe '.call' do
    let(:inventory_item1) { create(:cm_inventory_item, quantity_available: 10) }
    let(:inventory_item2) { create(:cm_inventory_item, quantity_available: 20) }
    let(:inventory_id_and_quantities) do
      [
        { inventory_id: inventory_item1.id, quantity: 5 },
        { inventory_id: inventory_item2.id, quantity: -3 }
      ]
    end
    let(:context) { Interactor::Context.new(inventory_id_and_quantities: inventory_id_and_quantities) }

    subject(:result) { described_class.call(context) }

    it 'updates the quantity_available for each inventory item based on provided quantities' do
      expect { result }.to change { inventory_item1.reload.quantity_available }.from(10).to(15)
                        .and change { inventory_item2.reload.quantity_available }.from(20).to(17)
    end

    context 'when inventory_id_and_quantities contains fewer entries than inventory items' do
      let(:inventory_id_and_quantities) do
        [{ inventory_id: inventory_item1.id, quantity: 5 }]
      end

      it 'only processes inventory items with matching quantities' do
        expect { result }.to change { inventory_item1.reload.quantity_available }.from(10).to(15)
      end
    end

    context 'when an inventory_id is not found' do
      let(:inventory_id_and_quantities) do
        [
          { inventory_id: inventory_item1.id, quantity: 5 },
          { inventory_id: 999, quantity: 10 }
        ]
      end

      it 'skips the missing inventory item and processes valid ones' do
        expect { result }.to change { inventory_item1.reload.quantity_available }.from(10).to(15)
      end
    end
  end

  describe '#adjust_quantity_available' do
    let(:inventory_item) { create(:cm_inventory_item, quantity_available: 10) }
    let(:syncer) { described_class.new }

    it 'increments quantity_available by the provided quantity' do
      expect {
        syncer.send(:adjust_quantity_available, inventory_item, 5)
      }.to change { inventory_item.reload.quantity_available }.from(10).to(15)
    end

    it 'decrements quantity_available when a negative quantity is provided' do
      expect {
        syncer.send(:adjust_quantity_available, inventory_item, -3)
      }.to change { inventory_item.reload.quantity_available }.from(10).to(7)
    end

    it 'uses with_lock to ensure thread-safe updates' do
      expect(inventory_item).to receive(:with_lock).and_call_original
      syncer.send(:adjust_quantity_available, inventory_item, 5)
    end
  end

  describe '#inventory_items' do
    let(:inventory_item) { create(:cm_inventory_item) }
    let(:syncer) { described_class.new }
    let(:inventory_id_and_quantities) do
      [{ inventory_id: inventory_item.id, quantity: 5 }]
    end
    let(:context) { Interactor::Context.new(inventory_id_and_quantities: inventory_id_and_quantities) }

    before do
      syncer.instance_variable_set(:@context, context)
    end

    it 'returns InventoryItem records matching the provided inventory_ids' do
      expect(syncer.send(:inventory_items)).to eq([inventory_item])
    end

    it 'returns an empty relation when inventory_id_and_quantities is empty' do
      allow(context).to receive(:inventory_id_and_quantities).and_return([])
      expect(syncer.send(:inventory_items)).to be_empty
    end
  end
end
