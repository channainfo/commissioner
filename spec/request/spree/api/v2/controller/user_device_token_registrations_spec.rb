require 'spec_helper'

RSpec.describe Spree::Api::V2::Storefront::UserDeviceTokenRegistrationsController, type: :controller do
  describe 'POST #create' do
    let(:user) { create(:cm_user) }

    before(:each) do
      allow(controller).to receive(:spree_current_user).and_return(user)
    end

    context 'when authorized' do
      it 'creates a new device token and returns a 200 status' do

        request.headers['X-Cm-App-Name'] = 'test-app'
        request.headers['X-Cm-App-Version'] = '1.0.0'

        post :create, params: {
          registration_token: 'device-token-id',
        }

        json_response = JSON.parse(response.body)
        device_attrs = json_response['data']['attributes']

        expect(response.status).to eq 200
        expect(device_attrs['user_id']).not_to be_nil
        expect(device_attrs['registration_token']).to eq 'device-token-id'
        expect(device_attrs['client_name']).to eq 'test-app'
        expect(device_attrs['client_version']).to eq '1.0.0'
      end
    end
  end

  describe 'DELETE destroy' do
    let(:user) { create(:cm_user) }

    before(:each) do
      allow(controller).to receive(:spree_current_user).and_return(user)
    end

    it 'remove device token ' do
      device_token = SpreeCmCommissioner::DeviceToken.create(
        client_version: '1.0.0',
        registration_token: 'device-token-id',
        client_name: 'jake mar',
        user_id: user.id
      )
      delete :destroy, params: { id: device_token.id }

      expect(response.status).to eq 200
    end
  end
end