require 'spec_helper'

describe 'Spree Oauth Spec', type: :request do

  # :password
  context 'grant_type: password' do
    let(:user) { build(:cm_user) }

    it 'successfully log user in with email' do
      allow(Spree.user_class).to receive(:find_user_by_login).with(user.email, nil).and_return(user)

      post "/spree_oauth/token", params: {
        "grant_type": "password",
        "username": user.email,
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

    it 'successfully log user in with phone_number' do
      allow(Spree.user_class).to receive(:find_user_by_login).with(user.phone_number, nil).and_return(user)

      post "/spree_oauth/token", params: {
        "grant_type": "password",
        "username": user.phone_number,
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

    it 'successfully log user in with login' do
      allow(Spree.user_class).to receive(:find_user_by_login).with(user.login, nil).and_return(user)

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
      allow(Spree.user_class).to receive(:find_user_by_login).with(user.login, nil).and_return(user)

      post "/spree_oauth/token", params: {
        "grant_type": "password",
        "username": user.login,
        "password": '12321232123',
      }

      expect(json_response_body["error"]).to eq I18n.t('authenticator.incorrect_password')
      expect(json_response_body.keys).to contain_exactly('error', 'error_description')
      expect(response.status).to eq 400
    end

    it 'return error on params missing' do
      allow(Spree.user_class).to receive(:find_user_by_login).with(user.login).and_return(user)

      post "/spree_oauth/token", params: {
        "grant_type": "password",
        "username": user.login,
      }

      expect(json_response_body["error"]).to eq I18n.t('authenticator.invalid_or_missing_params')
      expect(json_response_body.keys).to contain_exactly('error', 'error_description')
      expect(response.status).to eq 400
    end
  end

  # :password, but for id token
  context 'grant_type: password' do

    before do
      service_account = { project_id: 'bookmeplus' }
      fake_credentials = double('Firebase::Admin::Credentials',
        project_id: service_account[:project_id],
        service_account: service_account
      )
      stub_const('Firebase::Admin::Credentials', Class.new)

      allow(Firebase::Admin::Credentials).to receive(:from_json).and_return(fake_credentials)
      allow_any_instance_of(SpreeCmCommissioner::FirebaseIdTokenProvider)
        .to receive(:get_user_email)
        .and_return('bookmeplus@gmail.com')
    end

    it 'successfully log to existing user in' do
      existing_user = create(:cm_user_id_token)

      post "/spree_oauth/token", params: {
        "grant_type": "password",
        "id_token": generate(:cm_id_token),
      }

      recently_created_token = Spree::OauthAccessToken.last

      expect(recently_created_token.resource_owner_id).to eq existing_user.id
      expect(json_response_body.keys).to contain_exactly(
        'access_token',
        'token_type',
        'expires_in',
        'refresh_token',
        'created_at'
      )
    end

    it 'successfully register new user' do
      post "/spree_oauth/token", params: {
        "grant_type": "password",
        "id_token": generate(:cm_id_token),
      }

      expect(json_response_body.keys).to contain_exactly(
        'access_token',
        'token_type',
        'expires_in',
        'refresh_token',
        'created_at'
      )
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
