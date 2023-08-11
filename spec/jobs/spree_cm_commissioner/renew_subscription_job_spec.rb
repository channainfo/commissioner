require 'spec_helper'

RSpec.describe SpreeCmCommissioner::SubscriptionOrderExecutorJob do
  describe '#perform' do

    it 'invokes SubscriptionOrderCronExecutor.call' do
      expect(SpreeCmCommissioner::SubscriptionsOrderCronExecutor).to receive(:call)
      cron = SpreeCmCommissioner::SubscriptionOrderExecutorJob.new
      cron.perform
    end
  end
end
