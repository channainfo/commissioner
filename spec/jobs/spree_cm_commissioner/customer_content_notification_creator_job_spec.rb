require 'spec_helper'

RSpec.describe SpreeCmCommissioner::CustomerContentNotificationCreatorJob, type: :job do
  include ActiveJob::TestHelper

  let(:user1) { create(:cm_user) }
  let(:user2) { create(:cm_user) }
  let(:customer_notification) { create(:customer_notification, started_at: Date.current) }

  describe '#perform' do
    it 'accept options params' do
      notificable = double(:notificable)

      expect(SpreeCmCommissioner::CustomerContentNotification).to receive(:with).with(customer_notification: customer_notification).and_return(notificable)
      expect(notificable).to receive(:deliver).with(user1)

      described_class.new.perform(
        user_id: user1.id,
        customer_notification_id: customer_notification.id
      )
    end
  end
  describe '#perform_later' do
    let(:performed_job1) do
        described_class.perform_later(
          user_id: user1.id,
          customer_notification_id: customer_notification.id
        )
    end

    let(:performed_job2) do
        described_class.perform_later(
          user_id: user2.id,
          customer_notification_id: customer_notification.id
        )
    end

    context 'with validated params' do
      it 'performs the unique job only once' do
        expect {
          performed_job1
          performed_job2
          performed_job2
        }.to have_enqueued_job(described_class).exactly(2).times

      end
    end
  end
end

