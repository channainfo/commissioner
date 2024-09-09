require 'spec_helper'

RSpec.describe SpreeCmCommissioner::UserDeviceTokenDeregister do
  let!(:user1)  { create(:cm_user) }
  let!(:user2)  { create(:cm_user) }

  let!(:registration_token) { 'ios-device-token' }
  let!(:device_token) { create(:cm_device_token, user: user1, registration_token: registration_token) }

  describe '.call' do
    it 'remove fail if device_token not found' do
      context = described_class.call(device_token_id: device_token.id, user: user2 )
      expect(context.success?).to be false
      expect(context.message).to eq 'Device token not found'
    end

    it 'remove success if device_token found' do
      context = described_class.call(registration_token: device_token.registration_token, user: user1)
      expect(context.success?).to be true
    end
  end
end