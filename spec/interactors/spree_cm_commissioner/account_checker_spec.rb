require 'spec_helper'

RSpec.describe SpreeCmCommissioner::AccountChecker do
  let(:user) { create(:user) }

  describe '.call' do
    context 'login present' do
      it 'returns user login exist' do
        account_checker = described_class.call(login: user.email)

        expect(account_checker.success?).to eq true
        expect(account_checker.user).to eq user
      end

      it 'returns error if login does not exist' do
        token_auth_context = described_class.call(login: 'joez@gmail.com')

        expect(token_auth_context.success?).to eq false
        expect(token_auth_context.message).to eq('joez@gmail.com does not exist')
      end
    end

    context 'id_token present' do
      it 'returns user if id_token exist' do
        id_token = 'valid-id-token'
        success_checker = double(:user_id_token_checker, 'success?': true, user: user)

        expect(SpreeCmCommissioner::UserIdTokenChecker).to receive(:call)
                                                       .with(id_token: id_token)
                                                       .and_return(success_checker)

        account_checker = described_class.call(id_token: id_token)
        expect(account_checker.success?).to eq true
        expect(account_checker.user).to eq user
      end

      it 'returns error if login does not exist' do
        id_token = 'wrong-id-token'
        failed_checker = double(:user_id_token_checker, 'success?': false, user: nil, message: 'error-message')

        expect(SpreeCmCommissioner::UserIdTokenChecker).to receive(:call)
                                                       .with(id_token: id_token)
                                                       .and_return(failed_checker)

        account_checker = described_class.call(id_token: id_token)
        expect(account_checker.success?).to eq false
        expect(account_checker.user).to eq nil
        expect(account_checker.message).to eq 'error-message'
      end
    end
  end
end
