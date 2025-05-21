require 'spec_helper'

RSpec.describe SpreeCmCommissioner::EventLineItemsDateSyncerJob, type: :job do
  describe '#perform' do
    let(:taxonomy) { create(:taxonomy, kind: :event) }
    let(:event) { create(:taxon, name: 'BunPhum', taxonomy: taxonomy) }

    it 'calls EventLineItemsDateSyncer with the correct event' do
      expect(SpreeCmCommissioner::EventLineItemsDateSyncer).to receive(:call).with(event: event)
      described_class.new.perform(event.id)
    end
  end
end
