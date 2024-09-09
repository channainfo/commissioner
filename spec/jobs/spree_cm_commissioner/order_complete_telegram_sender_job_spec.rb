require 'spec_helper'

RSpec.describe SpreeCmCommissioner::OrderCompleteTelegramSenderJob, type: :job do
  include ActiveJob::TestHelper

  let(:order) { create(:order) }

  describe '#perform' do
    it 'find order & call OrderCompleteTelegramSender interactor' do
      subject = described_class.new

      expect(Spree::Order).to receive(:find).with(order.id).and_call_original
      expect(SpreeCmCommissioner::OrderCompleteTelegramSender).to receive(:call).with(order: order).and_call_original

      subject.perform(order.id)
    end
  end

  describe '.perform_now' do
    it 'find order & call OrderCompleteTelegramSender interactor' do
      expect(Spree::Order).to receive(:find).with(order.id).and_call_original
      expect(SpreeCmCommissioner::OrderCompleteTelegramSender).to receive(:call).with(order: order).and_call_original

      described_class.perform_now(order.id)
    end
  end
end
