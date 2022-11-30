require 'spec_helper'

RSpec.describe SpreeCmCommissioner::UserIdTokenAuthenticator do
  let(:user) { create(:user) }

  describe '.call' do
    context 'firebase id token success' do
      it 'return user if identity matched' do
        provider = {
          identity_type: 'google',
          email: 'channa.info@gmail.com',
          sub: '104389993318125584446'
        }

        create(
          :user_identity_provider, 
          user: user, 
          identity_type: 'google',
          sub: '104389993318125584446'
        )

        firebase_id_token_context = double(:firebase_context, 'success?': true, provider: provider)
        allow(SpreeCmCommissioner::FirebaseIdTokenProvider).to receive(:call).and_return(firebase_id_token_context)

        token_auth_context = SpreeCmCommissioner::UserIdTokenAuthenticator.call(id_token: 'fake', user: user)

        expect(token_auth_context.success?).to eq true
        expect(token_auth_context.provider).to eq provider
        expect(token_auth_context.user).to eq user
      end

      it 'return nil if user provider does not exist' do
        provider = {
          identity_type: 'google',
          email: 'channa.info@gmail.com',
          sub: '104389993318125584446'
        }

        firebase_id_token_context = double(:firebase_context, 'success?': true, provider: provider)
        allow(SpreeCmCommissioner::FirebaseIdTokenProvider).to receive(:call).and_return(firebase_id_token_context)

        token_auth_context = SpreeCmCommissioner::UserIdTokenAuthenticator.call(id_token: 'fake', user: user)

        expect(token_auth_context.success?).to eq false
        expect(token_auth_context.message).to eq('User identity provider for google not found in the system')
      end
    end

    context 'FirebaseIdToken failed' do
      it 'return failed context' do
        firebase_id_token_context = double(:firebase_context, 'success?': false, message: 'firebase_id_token.failed')
        allow(SpreeCmCommissioner::FirebaseIdTokenProvider).to receive(:call).and_return(firebase_id_token_context)

        token_auth_context = SpreeCmCommissioner::UserIdTokenAuthenticator.call(id_token: 'fake', user: nil)

        expect(token_auth_context.success?).to eq false
        expect(token_auth_context.message).to eq 'firebase_id_token.failed'
      end
    end
  end
end
