require 'spec_helper'

RSpec.describe SpreeCmCommissioner::ProductEventIdToChildrenSyncerJob, type: :job do
  describe '#perform' do
    let!(:product) { create(:product) }

    it 'calls ProductEventIdToChildrenSyncer with the correct product' do
      expect(SpreeCmCommissioner::ProductEventIdToChildrenSyncer).to receive(:call).with(product: product)
      described_class.new.perform(product.id)
    end
  end
end
