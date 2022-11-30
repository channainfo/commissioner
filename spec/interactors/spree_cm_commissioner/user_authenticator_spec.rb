require 'spec_helper'

RSpec.describe SpreeCmCommissioner::UserAuthenticator do
  let(:user) { create(:user, password: 'awesome-password') }

  describe '.call' do
    describe 'id_token is present' do
      it 'return context success when UserIdTokenAuthenticator is successully autheniticated' do
        ok_context = double(:firebase_context, 'success?': true, user: user)

        expect(SpreeCmCommissioner::UserIdTokenAuthenticator).to receive(:call)
                                                            .with(id_token: 'firebase-token')
                                                            .and_return(ok_context)

        result = described_class.call(id_token: 'firebase-token')

        expect(result.success?).to eq true
        expect(result.user).to eq user
      end

      it 'return context fail when UserIdTokenAuthenticator failed to authenticate' do
        failed_context = double(:firebase_context, 'success?': false, user: nil, message: 'failed-message')

        expect(SpreeCmCommissioner::UserIdTokenAuthenticator).to receive(:call)
                                                            .with(id_token: 'wrong-token')
                                                            .and_return(failed_context)

        result = described_class.call(id_token: 'wrong-token')

        expect(result.success?).to eq false
        expect(result.user).to eq nil
        expect(result.message).to eq 'failed-message'
      end
    end

    describe 'login and password present' do
      it 'return context success if UserPasswordAuthenticator is successfully authenticated' do
        ok_context = double(:firebase_context, 'success?': true, user: user)

        expect(SpreeCmCommissioner::UserPasswordAuthenticator).to receive(:call)
                                                            .with(login: 'mylogin', password: 'mypwd')
                                                            .and_return(ok_context)

        result = described_class.call(login: 'mylogin', password: 'mypwd')

        expect(result.success?).to eq true
        expect(result.user).to eq user
        expect(result.message).to eq nil
      end

      it 'return context success if UserPasswordAuthenticator is successfully authenticated' do
        ok_context = double(:firebase_context, 'success?': false, user: nil,
                                               message: 'un-authenticate')

        expect(SpreeCmCommissioner::UserPasswordAuthenticator).to receive(:call)
                                                            .with(login: 'mylogin', password: 'mypwd')
                                                            .and_return(ok_context)

        result = described_class.call(login: 'mylogin', password: 'mypwd')

        expect(result.success?).to eq false
        expect(result.user).to eq nil
        expect(result.message).to eq 'un-authenticate'
      end
    end
  end
end
