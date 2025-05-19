require 'spec_helper'

RSpec.describe SpreeCmCommissioner::InventoryItemSyncerJob, type: :job do
  describe '#perform' do
    let(:inventory_id_and_quantities) { [{ inventory_id: 1, quantity: 2 }, { inventory_id: 2, quantity: 1 }] }
    let(:line_item_ids) { [1, 2, 3] }
    let(:inventory_syncer) { instance_double(SpreeCmCommissioner::InventoryItemSyncer) }
    let(:telegram_syncer) { instance_double(SpreeCmCommissioner::TelegramSyncInventoryItemExceptionSender) }

    before do
      allow(SpreeCmCommissioner::InventoryItemSyncer).to receive(:call).and_return(inventory_syncer)
      allow(SpreeCmCommissioner::TelegramSyncInventoryItemExceptionSender).to receive(:call).and_return(telegram_syncer)
    end

    context 'when InventoryItemSyncer executes successfully' do
      it 'calls InventoryItemSyncer with correct parameters' do
        expect(SpreeCmCommissioner::InventoryItemSyncer).to receive(:call).with(
          inventory_id_and_quantities: inventory_id_and_quantities
        )

        subject.perform(inventory_id_and_quantities: inventory_id_and_quantities, line_item_ids: line_item_ids)
      end

      it 'does not call TelegramSyncInventoryItemExceptionSender' do
        expect(SpreeCmCommissioner::TelegramSyncInventoryItemExceptionSender).not_to receive(:call)

        subject.perform(inventory_id_and_quantities: inventory_id_and_quantities, line_item_ids: line_item_ids)
      end
    end

    context 'when InventoryItemSyncer raises an error' do
      let(:error) { StandardError.new('Sync failed') }

      before do
        allow(SpreeCmCommissioner::InventoryItemSyncer).to receive(:call).and_raise(error)
      end

      it 'calls TelegramSyncInventoryItemExceptionSender with correct parameters' do
        expect(SpreeCmCommissioner::TelegramSyncInventoryItemExceptionSender).to receive(:call).with(
          inventory_id_and_quantities: inventory_id_and_quantities,
          line_item_ids: line_item_ids,
          exception: error
        )

        expect {
          subject.perform(inventory_id_and_quantities: inventory_id_and_quantities, line_item_ids: line_item_ids)
        }.to raise_error(error)
      end
    end
  end
end
