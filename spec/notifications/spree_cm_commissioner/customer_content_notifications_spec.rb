require 'spec_helper'

RSpec.describe SpreeCmCommissioner::CustomerContentNotification do
  include ActiveJob::TestHelper

  let!(:url) { 'https://www.google.com' }
  let(:customer_notification) { create( :customer_notification, started_at: Date.current,url: url, excerpt: 'Promotion all products' ) }
  let!(:user) { create(:cm_user) }
  let!(:noticed) { described_class.with(customer_notification: customer_notification) }
  let!(:noticed_customer) do
    noticed.deliver(user)
    noticed
  end

  after do
    clear_enqueued_jobs
  end

  describe '#payload' do
    it 'return a payload id to be a string' do
      expect(noticed_customer.payload[:id]).to be_a String
    end
  end

  describe '#extra_payload' do
    it 'return a payload with customer_notification_id and url' do
      extra_payload = {
        customer_notification_id: customer_notification.id,
        url: url
      }
      expect(noticed_customer.extra_payload).to eq extra_payload
    end
  end

  describe '#image_url' do
    it 'return customer push notification image url' do
      image_url = 'http://www.google.com'
      customer_notification = double(:customer_notification,
                                      push_notification_image_url: image_url)
      allow(noticed_customer).to receive(:customer_notification).and_return(customer_notification)
      expect(noticed_customer.image_url).to eq image_url
    end
  end

  describe '#message' do
    it 'return push notification message' do
      customer_notification = SpreeCmCommissioner::Notification.last
      expect(noticed_customer.translatable_options[:message]).to eq 'Promotion all products'
    end
  end

  describe '#push_notificable?' do
    it 'pushable only user have device tokens' do
      user = create(:cm_user , device_tokens_count: 1)

      customer_notification = create(:customer_notification)
      noticed = described_class.with(customer_notification: customer_notification)
      noticed.recipient = user

      expect(noticed.push_notificable?).to eq true
    end
  end

  describe '#cleanup_device_token' do
    it 'removes selected device token' do
      device_token = create(:cm_device_token, user: user, registration_token: 'registration_token')

      noticed_customer.send(:cleanup_device_token, token: device_token.registration_token)
      expect { device_token.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
