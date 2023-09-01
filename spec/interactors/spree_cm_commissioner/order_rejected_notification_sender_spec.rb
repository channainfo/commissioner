require 'spec_helper'

RSpec.describe SpreeCmCommissioner::OrderRejectedNotificationSender do
  let(:user) { create(:cm_user) }
  let(:order) { create(:order_with_line_items , user: user , number: 'R23456789765') }
  let(:device_token) { create(:cm_device_token, user: user, registration_token: 'registration_token') }


  describe '#call' do

    before :each do
      allow(user).to receive(:device_token).and_return(device_token)
      described_class.call(order: order)
    end

    it 'should have in database' do
      expect(SpreeCmCommissioner::Notification.count).to eq 1

    end

    it 'returns right attributes' do
      notification = SpreeCmCommissioner::Notification.last;

      expect(notification.id).not_to be_nil
      expect(notification.recipient_type).to eq 'Spree::User'
      expect(notification.notificable_type).to eq 'Spree::Order'

      payload = notification.params[:payload]

      expect(payload[:order_id]).not_to be_nil
      expect(payload[:order_number]).to eq order.number
    end
  end
end