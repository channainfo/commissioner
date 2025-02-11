require 'spec_helper'

module SpreeCmCommissioner
  RSpec.describe NotificationBaseReader, type: :model do
    let(:user) { create(:cm_user) }
    let(:context) { Interactor::Context.new(user: user, id: 1) }

    # Dummy subclass to test the base class
    class DummyNotificationReader < NotificationBaseReader
      def validation!
        # Mock implementation
      end

      def mark_as_read!
        # Mock implementation
      end

      def decrement_user_unread_notification_count!
        # Mock implementation
      end
    end

    describe '#call' do
      it 'calls the required methods in order' do
        dummy_reader = DummyNotificationReader.new(context)

        expect(dummy_reader).to receive(:validation!).ordered
        expect(dummy_reader).to receive(:mark_as_read!).ordered
        expect(dummy_reader).to receive(:decrement_user_unread_notification_count!).ordered
        expect(SpreeCmCommissioner::UserUnreadNotificationCountJob).to receive(:perform_later).with(user.id).ordered

        dummy_reader.call
      end
    end

    describe 'abstract methods' do
      it 'raises NotImplementedError for #validation!' do
        expect { described_class.new(context).send(:validation!) }.to raise_error(NotImplementedError)
      end

      it 'raises NotImplementedError for #mark_as_read!' do
        expect { described_class.new(context).send(:mark_as_read!) }.to raise_error(NotImplementedError)
      end

      it 'raises NotImplementedError for #decrement_user_unread_notification_count!' do
        expect { described_class.new(context).send(:decrement_user_unread_notification_count!) }.to raise_error(NotImplementedError)
      end
    end

    describe '#consolidate_unread_count_async' do
      it 'enqueues UserUnreadNotificationCountJob with user id' do
        dummy_reader = DummyNotificationReader.new(context)

        expect(SpreeCmCommissioner::UserUnreadNotificationCountJob).to receive(:perform_later).with(user.id)

        dummy_reader.send(:consolidate_unread_count_async)
      end
    end
  end
end