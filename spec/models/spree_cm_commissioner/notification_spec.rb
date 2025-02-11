require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Notification, type: :model do
  describe "request_notifications" do
    it "return the latest notification if records have the same notification_id" do
      notification1 = create(:notification,
         type: 'order_requested_notification',
         read_at: nil,
         notificable_id: 1,
         notificable_type: 'Spree::Order'
      )
      notification2 = create(:notification,
        type: 'order_rejected_notification',
        read_at: nil,
        notificable_id: 1,
        notificable_type: 'Spree::Order'
      )

      notifications = SpreeCmCommissioner::Notification.request_notifications

      expect(notifications).to contain_exactly(notification2)
    end
  end

  let(:recipient) { create(:user, unread_notification_count: 0) }
  let(:notification) { create(:notification, recipient: recipient) }

  describe 'callbacks' do
    context 'after creation' do
      it 'increments the unread notification count' do
        expect {
          create(:notification, recipient: recipient)
        }.to change { recipient.reload.unread_notification_count }.by(1)
      end

      it 'enqueues the unread count consolidation job' do
        expect {
          create(:notification, recipient: recipient)
        }.to have_enqueued_job(SpreeCmCommissioner::UserUnreadNotificationCountJob)
      end
    end
  end

  describe 'private methods' do
    context 'when incrementing unread notification counts' do
      it 'calls consolidate_unread_count_async after increment' do
        expect(notification).to receive(:consolidate_unread_count_async)
        notification.send(:increment_user_unread_notification_count)
      end
    end
  end
end
