require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Stock::PermanentInventoryItemsGeneratorJob, type: :job do
  describe '#perform' do
    it 'calls PermanentInventoryItemsGenerator without any params' do
      expect(SpreeCmCommissioner::Stock::PermanentInventoryItemsGenerator).to receive(:call)

      subject.perform
    end
  end
end
