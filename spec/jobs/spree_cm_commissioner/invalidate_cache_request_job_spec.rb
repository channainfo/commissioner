require 'spec_helper'

RSpec.describe SpreeCmCommissioner::InvalidateCacheRequestJob do
  describe '#perform' do
    it 'invokes StateUpdater.call' do
      expect(SpreeCmCommissioner::InvalidateCacheRequest).to receive(:call).with(pattern: '/api/storefront/*')
      described_class.new.perform('/api/storefront/*')
    end
  end
end
