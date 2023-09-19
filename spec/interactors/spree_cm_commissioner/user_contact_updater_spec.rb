require 'spec_helper'

RSpec.describe SpreeCmCommissioner::UserContactUpdater do
  let!(:user) { create(:user, phone_number: '012555555', email: 'user@example.com') }

  describe '.call' do
    context 'with a valid user' do
      it 'updates phone_number' do
        new_phone_number = '85512111222'
        pin_code = create(:pin_code, :with_number, contact: new_phone_number,
                                                            type: 'SpreeCmCommissioner::PinCodeContactUpdate')

        context_update = described_class.call(
          pin_code: pin_code.code,
          pin_code_token: pin_code.token,
          phone_number: new_phone_number,
          user: user
        )

        expect(context_update.success?).to eq true
        expect(user.reload.phone_number).to eq('012111222')
      end

      it 'updates email' do
        new_email = 'new@example.com'
        pin_code = create(:pin_code, :with_email, contact: new_email,
                                                           type: 'SpreeCmCommissioner::PinCodeContactUpdate')
        context_update = described_class.call(
          pin_code: pin_code.code,
          pin_code_token: pin_code.token,
          email: new_email,
          user: user
        )

        expect(context_update.success?).to eq true
        expect(user.reload.email).to eq new_email
      end
    end

    context 'Update invalid user' do
      it 'updates invalid phone_number' do
        pin_code = create(:pin_code, :with_number, contact: '012999001',
                                                            type: 'SpreeCmCommissioner::PinCodeContactUpdate')
        context_update = described_class.call(
          pin_code: pin_code.code,
          pin_code_token: pin_code.token,
          phone_number: '012333555',
          user: user
        )

        expect(context_update.success?).to eq false
        expect(context_update.message).to eq 'Verification Code not found!'
        expect(user.reload.phone_number).to eq('012555555')
      end

      it 'updates phone_number that is already in use' do
        other_user_phone_number = '012111222'
        other_user = create(:user, phone_number: other_user_phone_number, email: 'other@example.com')
        pin_code = create(:pin_code, :with_number, contact: other_user_phone_number, type: 'SpreeCmCommissioner::PinCodeContactUpdate')

        p other_user.reload.phone_number
        p other_user.reload.intel_phone_number

        context_update = described_class.call(
          pin_code: pin_code.code,
          pin_code_token: pin_code.token,
          phone_number: other_user_phone_number,
          user: user
        )

        expect(context_update.success?).to eq false
        expect(context_update.message).to eq 'Phone number is already used'
        expect(user.reload.phone_number).to eq('012555555')
      end

      it 'updates email that is already in use' do
        other_user_email = 'other@example.com'
        other_user = create(:user, phone_number: '012111222', email: other_user_email)
        pin_code = create(:pin_code, :with_email, contact: other_user_email, type: 'SpreeCmCommissioner::PinCodeContactUpdate')

        context_update = described_class.call(
          pin_code: pin_code.code,
          pin_code_token: pin_code.token,
          email: other_user_email,
          user: user
        )

        expect(context_update.success?).to eq false
        expect(context_update.message).to eq 'Email is already used'
        expect(user.reload.email).to eq('user@example.com')
      end
    end
  end

  describe '#sanitize_contact' do
    it 'removes email if phone number exist' do
      options = { email: 'joe@vtenh.com', phone_number: '012999888' }
      registerer = described_class.new(options)
      registerer.send(:sanitize_contact)

      expect(registerer.context.email).to eq nil
    end

    it 'keep email is phone number is blank' do
      options = { email: 'joe@vtenh.com', phone_number: '' }
      registerer = described_class.new(options)
      registerer.send(:sanitize_contact)

      expect(registerer.context.email).to eq 'joe@vtenh.com'
    end
  end
end
