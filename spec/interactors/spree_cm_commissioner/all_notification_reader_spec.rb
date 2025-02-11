require 'spec_helper'

RSpec.describe SpreeCmCommissioner::AllNotificationReader do
  let(:user) { create(:user, unread_notification_count: 5) }
  let(:context) { Interactor::Context.new(user: user) }
  let(:unread_notifications) { create_list(:notification, 3, :unread, recipient: user) }
  let(:interactor) { described_class.new(context) }

  before do
    allow(context).to receive(:fail!).and_raise('Context failed')
  end

  describe '#validation!' do
    context 'when user is present' do
      it 'does not raise an error' do
        expect { interactor.send(:validation!) }.not_to raise_error
      end
    end

    context 'when user is nil' do
      let(:user) { nil }

      it 'fails the context with a "User not found" message' do
        expect(context).to receive(:fail!).with(message: 'User not found')
        expect { interactor.send(:validation!) }.to raise_error('Context failed')
      end
    end
  end

  describe '#mark_as_read!' do
    it 'marks all unread notifications as read' do
      unread_notifications # Create unread notifications
      expect(user.notifications.unread.count).to eq(3)

      interactor.send(:mark_as_read!)

      expect(user.notifications.unread.count).to eq(0)
    end
  end

  describe '#decrement_user_unread_notification_count!' do
    it 'decrements the user unread notification count to 0' do
      unread_notifications # Create unread notifications
      expect(user.unread_notification_count).to eq(8)

      interactor.send(:decrement_user_unread_notification_count!)

      user.reload
      expect(user.unread_notification_count).to eq(0)
    end
  end

  describe '#unread_notifications' do
    it 'returns the unread notifications for the user' do
      unread_notifications # Create unread notifications
      expect(interactor.send(:unread_notifications)).to match_array(unread_notifications)
    end
  end

  describe '.call' do
    let(:user) { create(:cm_user, unread_notification_count: 0) }
    let!(:notifications) { create_list(:notification, 2, :unread, recipient: user) }

    context 'Before call' do
      it 'update user unread_notification_count as 2' do
        expect(user.unread_notification_count).to eq(2)
      end
    end

    context 'After call' do
      subject(:call) { described_class.call(user: user) }

      it 'marks notification as read' do
        call
        expect(user.notifications.unread.count).to eq(0)
      end

      it 'updates user unread_notification_count to 0' do
        call
        expect(user.unread_notification_count).to eq(0)
      end

      it 'enques UserUnreadNotificationJob' do
        expect { call }.to have_enqueued_job(SpreeCmCommissioner::UserUnreadNotificationCountJob).with(user.id)
      end
    end
  end
end
