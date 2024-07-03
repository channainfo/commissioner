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

    context 'when device token is not exist' do
      it 'does not delete any device token' do
        user_device_token = SpreeCmCommissioner::UserDeviceTokenRegister.new(options_with_new_token)
        expect(SpreeCmCommissioner::DeviceToken).not_to receive(:delete)

        user_device_token.call
      end

      it 'create a new device token for the user' do
        user_device_token = SpreeCmCommissioner::UserDeviceTokenRegister.new(options_with_new_token)

        user_device_token.call

        expect(user_device_token.context.device_token).to be_persisted
      end
    end

    context 'when device token is exist' do
      it 'deletes the existing device token and creates a new unique device token' do
        # Create a new token with the same registration token but different client version
        user_device_token = SpreeCmCommissioner::UserDeviceTokenRegister.new(options_with_existing_token.merge(client_version: '2.0.0'))
        user_device_token.call

        # Verify the new token is created and the old one is deleted
        new_device_token = user.device_tokens.find_by(registration_token: 'ios-device-token')
        expect(new_device_token).to be_present
        expect(new_device_token.client_version).to eq '2.0.0'
        expect(new_device_token.device_type).to be_nil

        # Verify that only one device token exists with the updated attributes
        expect(SpreeCmCommissioner::DeviceToken.where(registration_token: 'ios-device-token').count).to eq 1
      end
    end
  end
end
