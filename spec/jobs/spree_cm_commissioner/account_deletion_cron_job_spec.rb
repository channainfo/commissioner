require 'spec_helper'

RSpec.describe SpreeCmCommissioner::AccountDeletionCronJob do
  describe '#perform' do
    it 'call account deletion cron executor' do
      expect(SpreeCmCommissioner::AccountDeletionCronExecutor).to receive(:call)
      described_class.new.perform
    end
  end
end