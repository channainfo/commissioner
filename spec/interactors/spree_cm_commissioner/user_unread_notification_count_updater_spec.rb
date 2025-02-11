require 'spec_helper'

RSpec.describe SpreeCmCommissioner::UserUnreadNotificationCountUpdater do
  let(:user) { create(:cm_user, unread_notification_count: 0) }
  let(:context) { Interactor::Context.new(user: user) }
  let(:interactor) { described_class.new(context) }

  describe '#update_unread_notification_count!' do
    subject(:update_unread_notification_count!) { interactor.send(:update_unread_notification_count!) }

    let!(:notification) { create(:notification, :unread, recipient: user) }

    it 'update user unread_notification_count 1' do
      update_unread_notification_count!

      expect(user.reload.unread_notification_count).to eq(1)
    end
  end

  describe '#call' do
    subject { described_class.call(user: user) }

    let!(:read_notification) { create(:notification, :read, recipient: user) }
    let!(:unread_notification) { create(:notification, :unread, recipient: user) }

    context 'when notification is present' do
      it 'updates the unread notification count for the recipient' do
        subject
        expect(user.unread_notification_count).to eq(1)
      end

      it 'sets the context user' do
        expect(interactor.user).to eq(user)
      end
    end
  end
end
