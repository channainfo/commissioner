require 'spec_helper'

RSpec.describe SpreeCmCommissioner::AccountLinkage do
  let(:user) { create(:user) }

  describe '.call' do
    context 'firebase id token success' do
      it 'create user identity provider if does not exist' do
        provider = {
          identity_type: 'google',
          email: 'channa.info@gmail.com',
          sub: '104389993318125584446',
          name: 'BookMe Plus'
        }

        firebase_id_token_context = double(:firebase_context, 'success?': true, provider: provider)
        allow(SpreeCmCommissioner::FirebaseIdTokenProvider).to receive(:call).and_return(firebase_id_token_context)

        account_linkage_context = described_class.call(id_token: 'fake', user: user)

        user.reload
        uips = user.user_identity_providers

        expect(account_linkage_context.success?).to eq true
        expect(account_linkage_context.identity_provider).to be_present

        expect(uips.length).to eq 1
        expect(uips[0].user_id).to eq user.id
        expect(uips[0].name).to eq 'BookMe Plus'
        expect(uips[0].email).to eq 'channa.info@gmail.com'
        expect(uips[0].sub).to eq '104389993318125584446'
        expect(uips[0].identity_type).to eq 'google'
      end

      it 'update create user identity provider if it already exist' do
        uip = create(:user_identity_provider, user: user)

        provider = {
          identity_type: 'google',
          email: 'channa.info@gmail.com',
          sub: '104389993318125584446',
          name: 'BookMe Plus'
        }

        firebase_id_token_context = double(:firebase_context, 'success?': true, provider: provider)
        allow(SpreeCmCommissioner::FirebaseIdTokenProvider).to receive(:call).and_return(firebase_id_token_context)

        account_linkage_context = described_class.call(id_token: 'fake', user: user)

        user.reload
        uip.reload

        expect(account_linkage_context.success?).to eq true
        expect(account_linkage_context.identity_provider).to be_present

        expect(user.user_identity_providers.length).to eq 1
        expect(uip.user_id).to eq user.id
        expect(uip.name).to eq 'BookMe Plus'
        expect(uip.email).to eq 'channa.info@gmail.com'
        expect(uip.sub).to eq '104389993318125584446'
        expect(uip.identity_type).to eq 'google'
      end

      it 'failed if provide google already has sub linked to another user' do
        other_user = create(:user)
        uip = create(:user_identity_provider, user: other_user)

        provider = {
          identity_type: 'google',
          sub: uip.sub,
          email: other_user.email,
          name: 'BookMe Plus',
        }

        firebase_id_token_context = double(:firebase_context, 'success?': true, provider: provider)
        allow(SpreeCmCommissioner::FirebaseIdTokenProvider).to receive(:call).and_return(firebase_id_token_context)

        account_linkage_context = described_class.call(id_token: 'fake', user: user)

        user.reload
        uip.reload

        expect(account_linkage_context.success?).to eq false
        expect(account_linkage_context.identity_provider).to be_present

        expect(user.user_identity_providers.length).to eq 0

        message = I18n.t('account_link.failure', identity_type: (provider[:identity_type]).to_s,
                                                 reason: account_linkage_context.identity_provider.errors.full_messages.join(','))
        expect(account_linkage_context.message).to eq message
      end
    end

    context 'FirebaseIdToken failed' do
      it 'return failed context' do
        firebase_id_token_context = double(:firebase_context, 'success?': false,
                                                              message: 'firebase_id_token.failed')
        allow(SpreeCmCommissioner::FirebaseIdTokenProvider).to receive(:call).and_return(firebase_id_token_context)

        account_linkage_context = SpreeCmCommissioner::AccountLinkage.call(id_token: 'fake', user: nil)

        expect(account_linkage_context.success?).to eq false
        expect(account_linkage_context.message).to eq 'firebase_id_token.failed'
      end
    end
  end
end
