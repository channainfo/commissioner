require 'spec_helper'

RSpec.describe Spree::Api::V2::Storefront::PinCodeCheckersController, type: :controller do
 let!(:pin_code) do
  create(:pin_code, contact: 'panhachom@gmail.com', contact_type: :email, expires_in: 900,
    type: 'SpreeCmCommissioner::PinCodeLogin')
 end

 describe 'POST update' do
  context 'when pin code is valid' do
    it 'return status ok' do
      set_application_token

      post :update, params: { id: pin_code.token, email: 'panhachom@gmail.com', code: pin_code.code,
                     type: 'SpreeCmCommissioner::PinCodeLogin' }

      expect(response.status).to eq 200
      expect(json_response_body['status']).to eq 'ok'
    end

    it 'return error' do
      set_application_token

      post :update,
           params: { id: pin_code.token, email: 'panhachom@gmail.com', code: '134122',
                     type: 'SpreeCmCommissioner::PinCodeLogin' }

      expect(response.status).to eq 400
      expect(json_response_body['error']).to eq I18n.t('pincode_checker.error_type.not_match')
    end
  end
 end
end
