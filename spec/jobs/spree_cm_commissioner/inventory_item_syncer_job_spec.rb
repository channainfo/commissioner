require 'spec_helper'

RSpec.describe SpreeCmCommissioner::InventoryItemSyncerJob, type: :job do
  let(:inventory_ids) { [1, 2, 3] }

  describe '#perform' do
    let(:syncer_class) { SpreeCmCommissioner::InventoryItemSyncer }

    subject { described_class.new.perform(inventory_ids) }

    it 'calls InventoryItemSyncer with correct parameters' do
      expect(syncer_class).to receive(:call).with(
        inventory_ids: inventory_ids
      )
      subject
    end
  end

  describe 'queue behavior' do
    it 'enqueues the job' do
      expect {
        described_class.perform_later(inventory_ids)
      }.to have_enqueued_job(described_class).with(inventory_ids)
    end
  end
end
