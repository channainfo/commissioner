require 'spec_helper'

RSpec.describe SpreeCmCommissioner::UserDeviceTokenRegister do
  let!(:user)  { create(:cm_user) }
  let!(:registration_token) { 'ios-device-token' }
  let!(:device_token) { create(:cm_device_token, user: user, registration_token: registration_token) }


  let!(:option_1 ) {
    {
      user: user,
      client_name: 'cm-market',
      client_version: '1.0.0',
      registration_token: device_token.registration_token
    }
  }

  let!(:option_2) {
    {
      user: user,
      client_name: 'cm-market',
      client_version: '1.0.0',
    }
  }

  let!(:option_3) {
    {
      user: user,
      client_name: 'cm-market',
      client_version: '1.0.0',
      registration_token: 'android-device-token',
    }
  }

  describe 'device_token_exist?' do
    it 'return true if device token exist' do

      user_device_token = SpreeCmCommissioner::UserDeviceTokenRegister.new(option_1)
      result = user_device_token.device_token_exist?

      expect(result).to eq true
      expect(user_device_token.context.device_token). to eq device_token

    end

    it 'return false if device token not exist' do

      user_device_token = SpreeCmCommissioner::UserDeviceTokenRegister.new(option_2)
      result = user_device_token.device_token_exist?

      expect(result).to eq false
    end
  end

  describe '#create device token' do
    it 'raise error if Registration token is blank' do

      user_device_token = SpreeCmCommissioner::UserDeviceTokenRegister.new(option_2)

      expect { user_device_token.create_device_token }.to raise_error Interactor::Failure
      expect(user_device_token.context.success?).to eq false
      expect(user_device_token.context.device_token.id).to be_nil
      expect(user_device_token.context.message).to eq "Registration token can't be blank"
    end

    it 'return success and does not create device token if device token already exists' do

      user_device_token = SpreeCmCommissioner::UserDeviceTokenRegister.new(option_1)
      user_device_token.create_device_token

      expect(user_device_token.context.device_token.id).to eq device_token.id
      expect(user_device_token.context.success?).to eq true
    end

    it 'create device token if it is valid' do

      user_device_token = SpreeCmCommissioner::UserDeviceTokenRegister.new(option_3)
      user_device_token.create_device_token

      expect(user_device_token.context.device_token.id).not_to be_nil
      expect(user_device_token.context.device_token.user_id).to eq user.id
      expect(user_device_token.context.device_token.client_name).to eq 'cm-market'
      expect(user_device_token.context.device_token.client_version).to eq '1.0.0'
      expect(user_device_token.context.device_token.registration_token).to eq 'android-device-token'

      expect(user_device_token.context.success?).to eq true
    end
  end
end