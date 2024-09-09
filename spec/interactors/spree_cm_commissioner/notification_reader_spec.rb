require 'spec_helper'

RSpec.describe SpreeCmCommissioner::NotificationReader do
  let(:user) { create(:cm_user) }
  describe '.call' do
    context 'when marking a specific notification as read' do
      it 'marks notification to read and set read_at value' do
        notification = create(:notification , read_at: nil)

        SpreeCmCommissioner::NotificationReader.call(id: notification.id)

        notification.reload

        expect(notification.read?).to eq true
        expect(notification.read_at).to_not eq nil
      end
      it 'does not change the read_at of notification if notification is read' do
        notification = create(:notification, read_at: Time.zone.now)
        read_at = notification.read_at

        SpreeCmCommissioner::NotificationReader.call(id: notification.id)

        expect(notification.read?).to eq true
        expect(notification.read_at).to eq read_at
      end
    end
  end

  context 'when marking all user unread notifications as read' do
    it 'marks all unread notifications as read' do
      unread_notifications = create_list(:notification, 3,
                                          read_at: nil,
                                          recipient_id: user.id,
                                          recipient_type: 'Spree::User'
                                        )

      SpreeCmCommissioner::NotificationReader.call(user: user)

      expect(user.notifications.unread_notifications.count).to eq 0
    end
  end
end