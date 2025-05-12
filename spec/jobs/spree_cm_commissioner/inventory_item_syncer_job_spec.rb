require 'spec_helper'

RSpec.describe SpreeCmCommissioner::InventoryItemSyncerJob, type: :job do
  let(:inventory_id_and_quantities) { [{inventory_id: 1, quantity: 2}, {inventory_id: 2, quantity: 1}] }

  describe '#perform' do
    let(:syncer_class) { SpreeCmCommissioner::InventoryItemSyncer }

    subject { described_class.new.perform(inventory_id_and_quantities:) }

    it 'calls InventoryItemSyncer with correct parameters' do
      expect(syncer_class).to receive(:call).with(
        inventory_id_and_quantities: inventory_id_and_quantities
      )
      subject
    end
  end

  describe 'queue behavior' do
    it 'enqueues the job' do
      expect {
        described_class.perform_later(inventory_id_and_quantities:)
      }.to have_enqueued_job(described_class).with(inventory_id_and_quantities:)
    end
  end
end
