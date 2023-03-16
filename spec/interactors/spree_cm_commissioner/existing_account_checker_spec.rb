require 'spec_helper'

RSpec.describe SpreeCmCommissioner::ExistingAccountChecker do
  describe '.call' do
    let(:user) { create(:cm_user, email: "l.regene10@gmail.com", login: 'l.regene', phone_number: "012934190" ) }

    context 'phone number' do
      it 'return error when phone number already exist' do
        context = described_class.call(login: user.phone_number)
        expect(context.success?).to be false
        expect(context.message).to eq I18n.t('account_checker.verify.already_exist', login: user.phone_number)
      end

      it 'return success when phone number not exist' do
        context = described_class.call(login: 'wrong-phone-number')
        expect(context.success?).to be true
        expect(context.message).to eq nil
      end
    end

    context 'email' do
      it 'return error when email already exist' do
        context = described_class.call(login: user.email)
        expect(context.success?).to be false
        expect(context.message).to eq I18n.t('account_checker.verify.already_exist', login: user.email)
      end

      it 'return success when email not exist' do
        context = described_class.call(login: 'wrong.email@gmail.com')
        expect(context.success?).to be true
        expect(context.message).to eq nil
      end
    end

    context 'login' do
      it 'return error when account already exist' do
        context = described_class.call(login: user.login)
        expect(context.success?).to be false
        expect(context.message).to eq I18n.t('account_checker.verify.already_exist', login: user.login)
      end

      it 'return success when account not exist' do
        context = described_class.call(login: 'wrong-login')
        expect(context.success?).to be true
        expect(context.message).to eq nil
      end
    end
  end
end