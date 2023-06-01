require 'spec_helper'

RSpec.describe SpreeCmCommissioner::CustomerNotificationSender do

  describe '#update customer_notification_send_at' do
    it 'does not update sent_at if customer_notification has already been sent' do
      sent_at = Time.now - 1.day
      customer_notification = create(:customer_notification, sent_at: sent_at)
      alert = described_class.new(customer_notification: customer_notification)
      alert.update_customer_notification_sent_at
      expect(customer_notification.sent_at).to eq sent_at
    end

    it 'update sent_at if it is nil' do
      customer_notification = create(:customer_notification, sent_at: nil)
      alert = described_class.new(customer_notification: customer_notification)
      alert.update_customer_notification_sent_at
      customer_notification.reload
      expect(customer_notification.sent_at).to_not eq nil
    end
  end

  describe '#end_users' do
    it 'return users that has at least one device token' do

      user= create(:cm_user, device_tokens_count: 1)

      customer_notification = create(:customer_notification)
      alert = described_class.new(customer_notification: customer_notification)
      users = alert.end_users

      expect(users.size).to eq 1
      expect(users.first.id).to eq user.id
    end

    it 'return users that either has or has not recieved notifications' do
      user_1 = create(:cm_user, device_tokens_count: 1)
      user_2 = create(:cm_user, device_tokens_count: 2)

      customer_notification = create(:customer_notification)
      alert = described_class.new(customer_notification: customer_notification)
      users = alert.end_users

      # pushed
      notification = create(
        :notification,
        recipient: user_1,
        notificable: customer_notification
      )

      expect(users.size).to eq 2

      # user 1
      expect(users.first.id).to eq user_1.id
      expect(users.first.notifications.size).to eq 1
      expect(users.first.notifications.first.id).to eq notification.id

      # users 2
      expect(users.last.id).to eq user_2.id
      expect(users.last.notifications.first).to eq nil
    end
  end

  describe '#users_not_recieved_notifications' do
    it 'return user_2 that has not recieved notification yet' do
      user_1 = create(:cm_user, device_tokens_count: 1)
      user_2 = create(:cm_user, device_tokens_count: 2)

      customer_notification = create(:customer_notification)
      alert = described_class.new(customer_notification: customer_notification)
      users = alert.users_not_recieved_notifications

      # pushed
      notification = create(
        :notification,
        recipient: user_1,
        notificable: customer_notification
      )

      expect(users.size).to eq 1
      expect(users.first.id).to eq user_2.id
    end
  end

  describe '#send_to_all_users' do
    it 'deliver notification to users' do
      user_1 = create(:cm_user, device_tokens_count: 0)
      user_2 = create(:cm_user, device_tokens_count: 2)
      user_3 = create(:cm_user, device_tokens_count: 1)

      customer_notification = create(:customer_notification)
      alert = described_class.new(customer_notification: customer_notification)

      expect(alert).to receive(:deliver_notification_to_user).with(user_2)
      expect(alert).to receive(:deliver_notification_to_user).with(user_3)

      alert.send_to_all_users
    end
  end

  describe '#call' do
    it 'sends notification and update record' do
      customer_notification = create(:customer_notification)
      alert = described_class.new(customer_notification: customer_notification)

      expect(alert).to receive(:send_notification)
      expect(alert).to receive(:update_customer_notification_sent_at)
      alert.call
    end
  end
end