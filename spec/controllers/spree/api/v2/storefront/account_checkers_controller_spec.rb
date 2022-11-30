require 'spec_helper'

RSpec.describe Spree::Api::V2::Storefront::AccountCheckersController, type: :controller do
  routes { Spree::Core::Engine.routes }

  let!(:user) { create(:user) }

  describe 'GET show' do
    context 'when AccountChecker is successful' do
      it 'return status ok' do
        set_application_token

        ok_checker = double(:account_checker, 'success?': true)
        expect(SpreeCmCommissioner::AccountChecker).to receive(:call)
                                                  .with({ "id_token" => "valid-token", "login" => "lyden@bookmebus.com" })
                                                  .and_return(ok_checker)

        get :show, params: {
          id_token: 'valid-token',
          login: 'lyden@bookmebus.com'
        }

        expect(response.status).to eq 200
        expect(response.body).to eq ''
      end
    end

    context 'when AccountChecker is not successful' do
      it 'return status 422 with error message' do
        set_application_token

        failed_checker = double(
          :account_checker,
          'success?': false,
          message: 'error-checker-message'
        )

        expect(SpreeCmCommissioner::AccountChecker).to receive(:call)
                                                  .with({ "id_token" => "valid-token", "login" => "lyden@bookmebus.com" })
                                                  .and_return(failed_checker)

        get :show, params: {
          id_token: 'valid-token',
          login: 'lyden@bookmebus.com'
        }

        expect(response.status).to eq 422
        expect(json_response_body).to eq({ 'error' => 'error-checker-message' })
      end
    end
  end
end
