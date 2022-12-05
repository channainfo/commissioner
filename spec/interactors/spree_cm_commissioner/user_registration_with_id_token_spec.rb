require 'spec_helper'

RSpec.describe SpreeCmCommissioner::UserRegistrationWithIdToken do
  let(:id_token){'eyJhbGciOiJSUzI1NiIsImtpZCI6Im....YQ9PBRrFvSvkzvlHb0lIgAqg'}

  describe '.call' do
    context 'return success' do
      it 'return user provider info' do
        provider = {
          identity_type: 'google',
          sub: 'helloworldthisissub'
        }

        subject = described_class.new(id_token: id_token)
        firebase_context = double(:firebase_context, success?: true, provider: provider)
        allow(SpreeCmCommissioner::FirebaseIdTokenProvider).to receive(:call).and_return(firebase_context)

        response = subject.call
        context = subject.context
        user_context = context.user

        expect(response['identity_type']).to eq(provider[:identity_type])
        expect(response['sub']).to eq(provider[:sub])
        expect(user_context).to_not eq(nil)
      end
    end 

    context 'return error' do
      it 'firebase verify id token fail' do
        subject = described_class.new(id_token: id_token)

        firebase_context = double(:firebase_context, success?: false, message: 'id token not valid or invalid signature')
        allow(SpreeCmCommissioner::FirebaseIdTokenProvider).to receive(:call).and_return(firebase_context)

        expect{subject.call}.to raise_error(Interactor::Failure)
      end

      it 'failed if already has sub linked to another user' do
        other_user = create(:user)
        uip = create(:user_identity_provider, user: other_user)

        provider = {
          identity_type: 'google',
          sub: uip.sub,
        }

        firebase_context = double(:firebase_context, 'success?': true, provider: provider)
        allow(SpreeCmCommissioner::FirebaseIdTokenProvider).to receive(:call).and_return(firebase_context)

        account_linkage_context = described_class.call(id_token: 'fake')

        uip.reload
        other_user.reload

        expect(account_linkage_context.success?).to eq false
        expect(account_linkage_context.message.first).to eq('Sub has already been taken')
      end
    end
  end

  describe '.link_user_account!'do
    it 'return user identity provider' do
      provider = {
        identity_type: 'google',
        sub: 'helloworldthisissub'
      }

      subject = described_class.new(id_token: id_token)
      user = subject.register_user!
      response = subject.link_user_account!(provider)

      expect(response['user_id']).to match(user.id)
      expect(response['sub']).to eq(provider[:sub])
      expect(response['identity_type']).to eq(provider[:identity_type])
    end
  end
end