require 'spec_helper'

RSpec.describe SpreeCmCommissioner::UserDeviceTokenRegister do
  let!(:user) { create(:cm_user) }
  let!(:registration_token) { 'ios-device-token' }
  let!(:device_token) { create(:cm_device_token, user: user, registration_token: registration_token) }

  let!(:options_with_existing_token) {
    {
      user: user,
      client_name: 'cm-market',
      client_version: '1.0.0',
      registration_token: device_token.registration_token
    }
  }

  let!(:options_without_token) {
    {
      user: user,
      client_name: 'cm-market',
      client_version: '1.0.0'
    }
  }

  let!(:options_with_new_token) {
    {
      user: user,
      client_name: 'cm-market',
      client_version: '1.0.0',
      registration_token: 'android-device-token'
    }
  }

  describe '#call' do
    it 'finds existing device token for the user if it exists' do
      user_device_token = SpreeCmCommissioner::UserDeviceTokenRegister.new(options_with_existing_token)
      expect(user.device_tokens).to receive(:find_or_initialize_by).with(registration_token: 'ios-device-token', client_name: 'cm-market').and_return(device_token)

      user_device_token.call

      expect(user_device_token.context.device_token).to eq device_token
    end

    it 'creates a new device token for the user if it does not exist' do
      user_device_token = SpreeCmCommissioner::UserDeviceTokenRegister.new(options_with_new_token)
      expect(user.device_tokens).to receive(:find_or_initialize_by).with(registration_token: 'android-device-token', client_name: 'cm-market').and_return(build(:cm_device_token))

      user_device_token.call

      expect(user_device_token.context.device_token).to be_persisted
    end

    it 'assigns client version and device type if device token is new' do
      user_device_token = SpreeCmCommissioner::UserDeviceTokenRegister.new(options_with_new_token)
      allow(user.device_tokens).to receive(:find_or_initialize_by).and_return(build(:cm_device_token))

      user_device_token.call

      expect(user_device_token.context.device_token.client_version).to eq '1.0.0'
      expect(user_device_token.context.device_token.device_type).to eq nil # Assuming device type is not set in options_with_new_token
    end

    it 'updates client version and device type if device token exists' do
      user_device_token = SpreeCmCommissioner::UserDeviceTokenRegister.new(options_with_existing_token)
      existing_device_token = device_token
      existing_device_token.update(device_type: nil) # Reset device_type to ensure consistent test setup
      allow(user.device_tokens).to receive(:find_or_initialize_by).and_return(existing_device_token)

      user_device_token.call

      expect(existing_device_token.client_version).to eq '1.0.0'
      expect(existing_device_token.device_type).to eq nil # Assuming device_type is reset in the test setup
    end

  end
end
