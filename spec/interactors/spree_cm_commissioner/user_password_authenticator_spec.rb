require 'spec_helper'

RSpec.describe SpreeCmCommissioner::UserPasswordAuthenticator do
  let(:user) { create(:cm_user, password: 'awesome-password') }

  describe '.call' do
    it 'return authenticator.invalid_login error if user login is invalid' do
      allow(Spree.user_class).to receive(:find_user_by_login).with(user.email, nil).and_return(nil)
      result_context = described_class.call(login: user.email)

      expect(result_context.success?).to eq false
      expect(result_context.message).to eq I18n.t('authenticator.incorrect_login')
    end

    it 'return authenticator.incorrect_password error if user password is invalid' do
      allow(Spree.user_class).to receive(:find_user_by_login).with(user.email, nil).and_return(user)
      result_context = described_class.call(login: user.email, password: 'wrong-password')

      expect(result_context.success?).to eq false
      expect(result_context.message).to eq I18n.t('authenticator.incorrect_password')
    end

    it 'return user if password is correct' do
      allow(Spree.user_class).to receive(:find_user_by_login).with(user.email, nil).and_return(user)
      result_context = described_class.call(login: user.email, password: 'awesome-password')

      expect(result_context.success?).to eq true
      expect(result_context.message.nil?).to eq true
    end
  end
end
