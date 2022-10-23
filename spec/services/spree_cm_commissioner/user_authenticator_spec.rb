require 'spec_helper'

# only for test execeptions, check: spec/request/spree/spree_oauth_spec.rb
RSpec.describe SpreeCmCommissioner::UserAuthenticator do
  let!(:user) { create(:user, password: '12345678', email: 'abc@vtenh.com') }

  context 'no exceptions' do
    it 'log into user when email & password valid' do
      context = double(:user_password_authenticator, 'user': user, 'success?': true)
      expect(SpreeCmCommissioner::UserPasswordAuthenticator)
          .to receive(:call)
          .with({ login: user.email, password: user.password })
          .and_return(context)

      params = { grant_type: 'password', username: user.email, password: user.password }
      authenticated_user = described_class.call?(params)

      expect(authenticated_user.email).to eq 'abc@vtenh.com'
    end
  end

  context 'no exceptions' do
    it 'log into user when email & password valid' do
      params = { grant_type: 'password', username: user.email, password: "wrong-password" }
      expect { described_class.call?(params) }.to raise_error(
                                                    Doorkeeper::Errors::DoorkeeperError, 
                                                    I18n.t('authenticator.incorrect_password')
                                                  )
    end
  end
end