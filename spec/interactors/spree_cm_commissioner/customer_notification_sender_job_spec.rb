require 'spec_helper'

RSpec.describe SpreeCmCommissioner::CustomerNotificationSenderJob do
  describe '#perform' do
    it 'invokes CustomerNotificationSender and complete if job success' do
      customer_notification = create(:customer_notification)

      options = {
        customer_notification: customer_notification
      }

      context_success = double(:firebase_deregistation, success?: true)
      expect(SpreeCmCommissioner::CustomerNotificationSender).to receive(:call).with(options).and_return(context_success)

      described_class.new.perform(customer_notification.id)
    end

    it 'invokes CustomerNotificationSender and raise error if job failed' do
      customer_notification_id = nil
      expect do
        described_class.new.perform(customer_notification_id)
      end.to raise_error ActiveRecord::RecordNotFound
    end
  end
end