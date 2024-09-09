require 'spec_helper'

RSpec.describe SpreeCmCommissioner::CustomerNotificationSender do
  let(:now) { '10-10-2021'.to_date }

  describe '#update_customer_notification_sent_at' do
    it 'updates sent_at if it is nil' do
      customer_notification = create(:customer_notification, sent_at: nil)
      alert = described_class.new(customer_notification: customer_notification)
      alert.update_sent_at
      customer_notification.reload
      expect(customer_notification.sent_at).to_not be_nil
    end
  end

  describe '#end_users' do
    it 'return users that has at least 1 device token' do

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

  describe '#users_not_received_notifications' do
    it 'return user_2 that has not recieved notification yet' do
      user_1 = create(:cm_user, device_tokens_count: 1)
      user_2 = create(:cm_user, device_tokens_count: 2)

      customer_notification = create(:customer_notification)
      alert = described_class.new(customer_notification: customer_notification)
      users = alert.users_not_received_notifications

      # pushed
      create(
        :notification,
        recipient: user_1,
        notificable: customer_notification
      )

      expect(users.size).to eq 1
      expect(users.first.id).to eq user_2.id
    end
  end

  describe '#send_notification' do
    it 'calls send_to_target_users if user_ids are not present' do
      customer_notification = create(:customer_notification)
      alert = described_class.new(customer_notification: customer_notification)

      expect(alert).to receive(:send_to_target_users)

      alert.send_notification
    end

    it 'calls send_to_specific_users with user_ids if user_ids are present' do
      user_ids = [1, 2]
      customer_notification = create(:customer_notification)
      alert = described_class.new(customer_notification: customer_notification, user_ids: user_ids)

      expect(alert).to receive(:send_to_specific_users).with(user_ids)

      alert.send_notification
    end
  end

  describe '#send_to_target_users' do
    it 'delivers notification to users with device tokens and updates sent_at' do
      user = create(:cm_user, device_tokens_count: 1)
      customer_notification = create(:customer_notification)
      alert = described_class.new(customer_notification: customer_notification)

      expect(SpreeCmCommissioner::CustomerContentNotificationCreator).to receive(:call).with(
        user_id: user.id,
        customer_notification_id: customer_notification.id
      )

      alert.send_to_target_users
    end

    it 'does not deliver notification to users without device tokens' do
      create(:cm_user, device_tokens_count: 0)
      customer_notification = create(:customer_notification)
      alert = described_class.new(customer_notification: customer_notification)

      expect(SpreeCmCommissioner::CustomerContentNotificationCreator).not_to receive(:call)

      alert.send_to_target_users
    end
  end

  describe '#call' do
    it 'sends notification and updates the record' do
      customer_notification = create(:customer_notification)
      alert = described_class.new(customer_notification: customer_notification)

      expect(alert).to receive(:send_notification)
      alert.call
    end
  end
end
