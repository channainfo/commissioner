require 'spec_helper'

RSpec.describe SpreeCmCommissioner::CustomerContentNotificationCreator do
  let(:user) { create(:cm_user) }
  let(:customer_notification) { create(:customer_notification, id: 1, started_at: Date.current) }

  describe '.call' do
    it 'fails when customer notification not found' do
      context = described_class.call(
        user_id: user.id,
        customer_notification_id: 0
      )
      expect(context.success?).to eq false
      expect(context.message).to eq 'Customer notification not found'
    end

    it 'fails when user not found' do
      context = described_class.call(
        user_id: 0,
        customer_notification_id: 1
      )
      expect(context.success?).to eq false
      expect(context.message).to eq 'User not found'
    end
  end
end