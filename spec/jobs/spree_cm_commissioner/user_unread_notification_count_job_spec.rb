require 'spec_helper'

RSpec.describe SpreeCmCommissioner::UserUnreadNotificationCountJob do
  describe '#perform' do
    let(:notification) { create(:notification) }

    it 'invokes UserUnreadNotificationCountJob.call' do
      expect(SpreeCmCommissioner::UserUnreadNotificationCountUpdater).to receive(:call).with(user: notification.recipient)
      described_class.new.perform(notification.recipient_id)
    end
  end
end
