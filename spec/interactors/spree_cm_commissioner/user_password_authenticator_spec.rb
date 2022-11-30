require 'spec_helper'

RSpec.describe SpreeCmCommissioner::UserPasswordAuthenticator do
  let(:user) { create(:user, password: 'awesome-password') }

  describe 'validate_password' do
    it 'returns false if password is invalid' do
      authenticator = described_class.new(password: 'wrong-password')
      password_valid = authenticator.send(:validate_password, user)

      expect(password_valid).to eq false
    end

    it 'returns true if password is valid' do
      authenticator = described_class.new(password: 'awesome-password')
      password_valid = authenticator.send(:validate_password, user)

      expect(password_valid).to eq true
    end
  end

  describe '.call' do
    it 'return authenticator.invalid_login error if user login is invalid' do
      allow(Spree.user_class).to receive(:find_first_by_auth_conditions).with({:email => user.email }).and_return(nil)
      result_context = described_class.call(login: user.email)

      expect(result_context.success?).to eq false
      expect(result_context.message).to eq I18n.t('authenticator.incorrect_login')
    end

    it 'return authenticator.incorrect_password error if user password is invalid' do
      allow(Spree.user_class).to receive(:find_first_by_auth_conditions).with({:email => user.email }).and_return(user)
      result_context = described_class.call(login: user.email, password: 'wrong-password')

      expect(result_context.success?).to eq false
      expect(result_context.message).to eq I18n.t('authenticator.incorrect_password')
    end

    it 'return user if password is correct' do
      allow(Spree.user_class).to receive(:find_first_by_auth_conditions).with({:email => user.email }).and_return(user)
      result_context = described_class.call(login: user.email, password: 'awesome-password')

      expect(result_context.success?).to eq true
      expect(result_context.message.nil?).to eq true
    end
  end
end
