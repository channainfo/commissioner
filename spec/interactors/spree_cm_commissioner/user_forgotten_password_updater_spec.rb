require 'spec_helper'

RSpec.describe SpreeCmCommissioner::UserForgottenPasswordUpdater do
  it 'reset password when email & pin code is valid' do
    old_password = "old-password"
    new_password = "new-password"

    user = create(:cm_user, email: "eg@cm.com", password: old_password)
    pin_code = create(:pin_code, :with_email, contact: 'eg@cm.com', type: 'SpreeCmCommissioner::PinCodeForgetPassword')

    context = described_class.call(
      email: 'eg@cm.com',
      pin_code: pin_code.code,
      pin_code_token: pin_code.token,
      password: new_password,
      password_confirmation: new_password,
    )

    expect(context.success?).to be true
    expect(user.valid_password?(new_password))
  end

  it 'reset password when phone & pin code is valid' do
    old_password = "old-password"
    new_password = "new-password"

    user = create(:cm_user, phone_number: "012345678", password: old_password)
    pin_code = create(:pin_code, :with_number, contact: '012345678', type: 'SpreeCmCommissioner::PinCodeForgetPassword')

    context = described_class.call(
      phone_number: '012345678',
      pin_code: pin_code.code,
      pin_code_token: pin_code.token,
      password: new_password,
      password_confirmation: new_password
    )

    expect(context.success?).to be true
    expect(user.valid_password?(new_password))
  end

  it 'error when user is not exist' do
    user = create(:cm_user, email: "eg@cm.com")

    context = described_class.call(
      phone_number: 'wrong.email@cm.com',
      pin_code: '',
      pin_code_token: '',
      password: '11111',
      password_confirmation: '11111'
    )

    expect(context.success?).to be false
    expect(context.user).to eq nil
    expect(context.message).to eq 'wrong.email@cm.com not exist'
  end

  it 'error when pin code is invalid' do
    user = create(:cm_user)
    pin_code = create(:pin_code, :with_email, contact: user.email, type: 'SpreeCmCommissioner::PinCodeForgetPassword')

    context = described_class.call(
      email: user.email,
      pin_code: '000000',
      pin_code_token: pin_code.token,
      password: 'password',
      password_confirmation: 'password'
    )

    expect(context.success?).to be false
    expect(context.message).to eq "Verification code is not valid"
  end
end
