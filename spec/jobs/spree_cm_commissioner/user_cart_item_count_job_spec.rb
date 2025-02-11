require 'spec_helper'

RSpec.describe SpreeCmCommissioner::UserCartItemCountJob do
  describe '#perform' do
    let(:order) { create(:order) }

    it 'invokes UserCartItemCountJob.call' do
      expect(SpreeCmCommissioner::UpdateUserCartItemCountHandler).to receive(:call).with(order: order)
      described_class.new.perform(order.id)
    end
  end
end
