require 'spec_helper'

# only for test execeptions, check: spec/request/spree/spree_oauth_spec.rb
RSpec.describe SpreeCmCommissioner::UserAuthenticator do
  let!(:user) { create(:user, password: '12345678', email: 'abc@cm.com') }

  context 'no exceptions' do
    it 'log into user when email & password valid' do
      context = double(:user_password_authenticator, 'user': user, 'success?': true)
      expect(SpreeCmCommissioner::UserPasswordAuthenticator)
          .to receive(:call)
          .with({ login: user.email, password: user.password, tenant_id: nil })
          .and_return(context)

      params = { grant_type: 'password', username: user.email, password: user.password }
      authenticated_user = described_class.call!(params)

      expect(authenticated_user.email).to eq 'abc@cm.com'
    end
  end

  context 'no exceptions' do
    it 'log into user when email & password valid' do
      params = { grant_type: 'password', username: user.email, password: "wrong-password" }
      expect { described_class.call!(params) }.to raise_error(
                                                    Doorkeeper::Errors::DoorkeeperError,
                                                    I18n.t('authenticator.incorrect_password')
                                                  )
    end
  end

  describe '.flow_type' do
    it 'return [telegram_web_app_auth] when params contain telegram_init_data & tg_bot' do
      flow_type = described_class.flow_type({ telegram_init_data: 'anything-as-long-as-present', tg_bot: 'bookmeplus_bot' })

      expect(flow_type).to eq 'telegram_web_app_auth'
    end

    it 'returns [login_auth] when params contain username & password' do
      flow_type = described_class.flow_type({ username: user.email, password: user.password })

      expect(flow_type).to eq 'login_auth'
    end

    it 'returns [social_auth] when params contain id_token' do
      flow_type = described_class.flow_type({ id_token: generate(:cm_id_token) })

      expect(flow_type).to eq 'social_auth'
    end

    it 'raises error when params are invalid' do
      expect { described_class.flow_type({}) }.to raise_error(
                                                    Doorkeeper::Errors::DoorkeeperError,
                                                    I18n.t('authenticator.invalid_or_missing_params')
                                                  )
    end
  end
end
