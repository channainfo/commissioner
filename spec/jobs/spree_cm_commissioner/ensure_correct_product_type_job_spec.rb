require 'spec_helper'

RSpec.describe SpreeCmCommissioner::EnsureCorrectProductTypeJob do
  describe '#perform' do
    it 'invokes EnsureCorrectProductType.call' do
      expect(SpreeCmCommissioner::EnsureCorrectProductType).to receive(:call)
      described_class.new.perform
    end
  end
end
