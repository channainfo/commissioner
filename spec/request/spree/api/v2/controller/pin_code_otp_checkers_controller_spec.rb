require 'spec_helper'

RSpec.describe Spree::Api::V2::Storefront::PinCodeOtpCheckersController, type: :controller do
 let!(:pin_code) do
  create(:pin_code, contact: 'vaneath@gmail.com', contact_type: :email, expires_in: 900,
    type: 'SpreeCmCommissioner::PinCodeOtp')
 end

 describe 'POST update' do
  context 'when pin code is valid' do
    it 'return status ok' do
      set_application_token

      post :update, params: { pin_code_token: pin_code.token, email: 'vaneath@gmail.com', pin_code: pin_code.code }

      expect(response.status).to eq 200
      expect(json_response_body['status']).to eq 'ok'
    end

    it 'return error' do
      set_application_token

      post :update,
           params: { pin_code_token: pin_code.token, email: 'vaneath@gmail.com', pin_code: '134122' }

      expect(response.status).to eq 400
      expect(json_response_body['error']).to eq I18n.t('pincode_checker.error_type.not_match')
    end
  end
 end
end
