require 'spec_helper'

RSpec.describe SpreeCmCommissioner::NotificationReader, type: :model do
  let(:notification) { create(:notification, :unread) }
  let(:user) { notification.recipient }
  let(:context) { Interactor::Context.new(id: notification.id) }
  let(:interactor) { described_class.new(context) }

  before do
    allow(context).to receive(:fail!).and_raise('Context failed')
  end

  describe '#validation!' do
    context 'when notification is present' do
      it 'does not raise an error' do
        expect { interactor.send(:validation!) }.not_to raise_error
      end
    end

    context 'when notification is nil' do
      before do
        allow(interactor).to receive(:notification).and_return(nil)
      end

      it 'fails the context with a "Notification not found" message' do
        expect(context).to receive(:fail!).with(message: 'Notification not found')
        expect { interactor.send(:validation!) }.to raise_error('Context failed')
      end
    end
  end

  describe '#mark_as_read!' do
    it 'marks the notification as read' do
      expect(notification.read?).to be_falsey

      interactor.send(:mark_as_read!)

      notification.reload
      expect(notification.read?).to be_truthy
    end
  end

  describe '#decrement_user_unread_notification_count!' do
    it 'decrements the user unread notification count by 1' do
      user.update!(unread_notification_count: 5)
      expect(user.unread_notification_count).to eq(5)

      interactor.send(:decrement_user_unread_notification_count!)

      user.reload
      expect(user.unread_notification_count).to eq(4) # 5 - 1 = 4
    end
  end

  describe '#user' do
    it 'returns the recipient of the notification' do
      expect(interactor.send(:user)).to eq(user)
    end
  end

  describe '#notification' do
    it 'returns the notification with the given id' do
      expect(interactor.send(:notification)).to eq(notification)
    end

    context 'when notification does not exist' do
      let(:context) { Interactor::Context.new(id: 999) }

      it 'returns nil' do
        expect(interactor.send(:notification)).to be_nil
      end
    end
  end

  describe '.call' do
    let(:user) { create(:cm_user, unread_notification_count: 0) }
    let(:notification) { create(:notification, :unread, recipient: user) }

    context 'Before call' do
      it 'update user unread_notification_count as 1' do
        notification
        expect(user.unread_notification_count).to eq(1)
      end
    end

    context 'After call' do
      subject(:call) { described_class.call(id: notification.id) }

      it 'marks notification as read' do
        call
        expect(notification.reload.read?).to be_truthy
      end

      it 'decrease user unread_notification_count by 1' do
        call
        expect(user.reload.unread_notification_count).to eq(0)
      end

      it 'enques UserUnreadNotificationJob' do
        expect {
          call
        }.to have_enqueued_job(SpreeCmCommissioner::UserUnreadNotificationCountJob).with(user.id)
      end
    end
  end
end
