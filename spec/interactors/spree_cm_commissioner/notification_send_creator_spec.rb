require 'spec_helper'

RSpec.describe SpreeCmCommissioner::NotificationSendCreator do
  let(:customer_notification) { create(:customer_notification) }
  let(:taxon) { create(:taxon) }

  describe '#call' do
    context 'when send_all is true' do
      it 'calls handle_send_all method' do
        interactor = described_class.new(send_all: true, customer_notification: customer_notification)
        expect(interactor).to receive(:handle_send_all)
        interactor.call
      end
    end

    context 'when send_all is false' do
      it 'calls handle_send_specific method' do
        interactor = described_class.new(send_all: false, customer_notification: customer_notification)
        expect(interactor).to receive(:handle_send_specific)
        interactor.call
      end
    end
  end

  describe '#handle_send_all' do
    context 'when customer_notification has notification_taxons' do
      before do
        create(:cm_notification_taxon, customer_notification: customer_notification, taxon: taxon)
      end

      it 'sends notification to specific users and sets notice_key' do
        interactor = described_class.new(send_all: true, customer_notification: customer_notification)
        expect(SpreeCmCommissioner::CustomerNotificationSenderJob).to receive(:perform_later).with(customer_notification.id, any_args)
        interactor.call
        expect(interactor.context.notice_key).to eq 'notification.send_specific_in_progress'
      end
    end

    context 'when customer_notification does not have notification_taxons' do
      it 'sends notification to all users and sets notice_key' do
        interactor = described_class.new(send_all: true, customer_notification: customer_notification)
        expect(SpreeCmCommissioner::CustomerNotificationSenderJob).to receive(:perform_later).with(customer_notification.id, nil)
        interactor.call
        expect(interactor.context.notice_key).to eq 'notification.send_all_in_progress'
      end
    end
  end

  describe '#handle_send_specific' do
    it 'sends notification to specific users and sets notice_key' do
      interactor = described_class.new(send_all: false, customer_notification: customer_notification)
      expect(SpreeCmCommissioner::CustomerNotificationSenderJob).to receive(:perform_later).with(customer_notification.id, any_args)
      interactor.call
      expect(interactor.context.notice_key).to eq 'notification.send_specific_in_progress'
    end
  end
end
