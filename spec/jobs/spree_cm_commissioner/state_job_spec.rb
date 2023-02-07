require 'spec_helper'

RSpec.describe SpreeCmCommissioner::StateJob do
  describe '#perform' do
    let(:state) {create(:state, name: "state", total_inventory: 0)}

    it 'invokes StateUpdater.call' do
      expect(SpreeCmCommissioner::StateUpdater).to receive(:call).with(state: state)
      described_class.new.perform(state.id)
    end
  end
end
