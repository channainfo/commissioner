require 'spec_helper'

RSpec.describe Spree::Api::V2::Storefront::UserRegistrationWithPinCodesController, type: :controller do
  describe 'POST #create' do

    context 'with valid pincode and user attributes' do
      it 'registers user' do
        set_application_token

        pin_code = create(:pin_code, :with_number, contact: '012333444',
                                                            type: 'SpreeCmCommissioner::PinCodeRegistration')

        params = {
          pin_code: pin_code.code,
          pin_code_token: pin_code.token,
          phone_number: '012333444',
          first_name: 'Joe',
          last_name: 'ann',
          password: '123456',
          gender: 'female',
          dob: '2000-10-30'
        }

        post :create, params: params

        expect(response.status).to eq 200

      end
    end

    context 'when pincode invalid' do
      it 'return pin code error' do
        set_application_token

        params = {
          pin_code: 'invalid',
          pin_code_token: 'invalid',
          phone_number: '012333444',
          first_name: 'Joe',
          last_name: 'ann',
          password: '123456',
          gender: 'female',
          dob: '2000-10-30'
        }

        post :create, params: params

        expect(response.status).to eq 422
        expect(json_response_body).to match({ 'error' => 'Verification Code not found!' })
      end
    end

    context 'with valid pincode and invalid user attributes' do
      it 'return user error' do
        set_application_token
        pin_code = create(:pin_code, :with_number, contact: '012333444',
                                                            type: 'SpreeCmCommissioner::PinCodeRegistration')

        params = {
          pin_code: pin_code.code,
          pin_code_token: pin_code.token,
          phone_number: '012333444',
          first_name: 'Joe',
          last_name: 'ann',
          password: '123456',
          password_confirmation: 'mismatched',
          gender: 'female',
          dob: '2000-10-30'
        }

        post :create, params: params

        expect(response.status).to eq 422
      end
    end
  end
end