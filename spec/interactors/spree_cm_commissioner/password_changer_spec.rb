require 'spec_helper'

RSpec.describe SpreeCmCommissioner::PasswordChanger do
  let!(:current_password) { '12345678' }
  let!(:password) { '87654321' }
  let!(:user) { create(:cm_user, password: current_password) }
  let!(:valid_options) do
    { user: user, current_password: current_password, password: password,
      password_confirmation: password }
  end

  subject { SpreeCmCommissioner::PasswordChanger.new(valid_options)}

  describe '.call' do
    
    it 'update user password if attributes are correct' do
      password_changer_context = described_class.call(valid_options)

      expect(password_changer_context.success?).to eq true
    end

    it 'return fail if password not match' do
      invalid_options = valid_options.merge(current_password: 'anything')
      password_changer_context = described_class.call(invalid_options)

      expect(password_changer_context.success?).to eq false
      expect(password_changer_context.message).to eq I18n.t('authenticator.incorrect_password')
    end
  end
end