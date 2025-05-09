require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Stock::InventoryItemsGeneratorJob, type: :job do
  include ActiveJob::TestHelper

  describe '#perform' do
    let(:variant) { create(:variant) }
    let(:variant_id) { variant.id }

    it 'finds the variant by ID and calls InventoryItemsGenerator with the variant' do
      # Mock the variant lookup
      expect(Spree::Variant).to receive(:find).with(variant_id).and_return(variant)

      # Mock the InventoryItemsGenerator call
      expect(SpreeCmCommissioner::Stock::InventoryItemsGenerator).to receive(:call).with(variant: variant)

      # Perform the job
      described_class.perform_now(variant_id: variant_id)
    end

    context 'when variant is not found' do
      it 'raises an ActiveRecord::RecordNotFound error' do
        # Mock the variant lookup to raise RecordNotFound
        allow(Spree::Variant).to receive(:find).with(variant_id).and_raise(ActiveRecord::RecordNotFound)

        expect {
          described_class.perform_now(variant_id: variant_id)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'job queue' do
    it 'enqueues the job in the default queue' do
      expect {
        described_class.perform_later(variant_id: 1)
      }.to have_enqueued_job(described_class).with(variant_id: 1).on_queue('default')
    end
  end
end
