require 'spec_helper'

describe 'Spree Oauth Spec', type: :request do
  # :password
  context 'grant_type: password' do
    it 'successfully log user in' do
      user = create(:user)

      post "/spree_oauth/token", params: {
        "grant_type": "password",
        "username": user.login,
        "password": user.password,
      }

      expect(json_response_body.keys).to contain_exactly(
        'access_token',
        'token_type',
        'expires_in',
        'refresh_token',
        'created_at'
      )
    end

    it 'return error on incorrect password' do
      user = create(:user)

      post "/spree_oauth/token", params: {
        "grant_type": "password",
        "username": user.login,
        "password": '12321232123',
      }

      expect(json_response_body["error"]).to eq I18n.t('authenticator.incorrect_password')
      expect(json_response_body.keys).to contain_exactly('error', 'error_description')
      expect(response.status).to eq 400
    end
  end

  # :client_credentials
  context 'grant_type: client_credentials' do
    it 'return tokens with valid client id & secret' do
      oauth_application = create(:oauth_application)

      post "/spree_oauth/token", params: {
        "grant_type": "client_credentials",
        "client_id": oauth_application.uid,
        "client_secret": oauth_application.secret,
      }

      expect(json_response_body.keys).to contain_exactly(
        'access_token',
        'token_type',
        'expires_in',
        'created_at',
      )
    end

    it 'return error on invalid client_secret' do
      oauth_application = create(:oauth_application)

      post "/spree_oauth/token", params: {
        "grant_type": "client_credentials",
        "client_id": oauth_application.uid,
        "client_secret": "invalid client secret",
      }

      expect(json_response_body["error"]).to eq "invalid_client"
      expect(json_response_body.keys).to contain_exactly('error', 'error_description')
      expect(response.status).to eq 401
    end

    it 'return error on invalid client_secret' do
      oauth_application = create(:oauth_application)

      post "/spree_oauth/token", params: {
        "grant_type": "client_credentials",
        "client_id": "invalid client_id",
        "client_secret": oauth_application.secret,
      }

      expect(json_response_body["error"]).to eq "invalid_client"
      expect(json_response_body.keys).to contain_exactly('error', 'error_description')
      expect(response.status).to eq 401
    end
  end
end