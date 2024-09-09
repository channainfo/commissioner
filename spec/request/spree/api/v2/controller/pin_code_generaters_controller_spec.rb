require 'spec_helper'

RSpec.describe Spree::Api::V2::Storefront::PinCodeGeneratorsController, type: :controller do
  describe 'POST create' do
    context 'with valid params' do
      it 'create new pin code' do
        allow(controller).to receive(:validate_recaptcha).and_return(true)

        set_application_token

        post :create, params: { email: 'john@gmail.com' , type: 'SpreeCmCommissioner::PinCodeLogin' }

        expect(response.status).to eq 201
        expect(json_response_body['data']['attributes']['contact']).to eq 'john@gmail.com'
        expect(json_response_body['data']['attributes']['type']).to eq 'SpreeCmCommissioner::PinCodeLogin'
      end
    end
    context 'with ininvalid params' do
      it 'return error' do
        allow(controller).to receive(:validate_recaptcha).and_return(true)

        set_application_token

        post :create, params: { email: '0964103875', type: 'SpreeCmCommissioner::PinCodeLogin' }

        expect(response.status).to eq 400
        expect(json_response_body['error']).to eq 'Invalid email address'
      end
    end
  end
end
