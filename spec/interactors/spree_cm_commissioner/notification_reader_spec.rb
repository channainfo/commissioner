require 'spec_helper'

RSpec.describe SpreeCmCommissioner::NotificationReader do
  let(:user) { create(:cm_user) }
  describe '.call' do
    context 'notification is unread' do
      it 'marks notification to read and set read_at value' do
        notification = create(:notification , read_at: nil)

        SpreeCmCommissioner::NotificationReader.call(id: notification.id)

        notification.reload

        expect(notification.read?).to eq true
        expect(notification.read_at).to_not eq nil
      end
    end
  end

  context 'notification is read' do
    it 'does not change the read_at of notification' do
      notification = create(:notification, read_at: Time.zone.now)
      read_at = notification.read_at

      SpreeCmCommissioner::NotificationReader.call(id: notification.id)

      expect(notification.read?).to eq true
      expect(notification.read_at).to eq read_at
    end
  end

end