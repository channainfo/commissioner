require 'spec_helper'

RSpec.describe SpreeCmCommissioner::InventoryItemGeneratorJob, type: :job do
  describe '#perform' do
    it 'calls InventoryItemGenerator' do
      expect(SpreeCmCommissioner::InventoryItemGenerator).to receive(:call)

      subject.perform
    end
  end
end
