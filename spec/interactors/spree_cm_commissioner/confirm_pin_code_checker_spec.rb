require 'spec_helper'
require 'bcrypt'

RSpec.describe SpreeCmCommissioner::ConfirmPinCodeChecker do
  let(:user_confirm_pin_code) { BCrypt::Password.create('987654') }

  describe '#call' do
    context 'when input pin code is blank' do
      let(:input_pin_code) { '' }

      it 'fails with a pin_code_must_not_blank message' do
        interactor = SpreeCmCommissioner::ConfirmPinCodeChecker.call(user_pin_code: user_confirm_pin_code, input_pin_code: input_pin_code)
        expect(interactor.failure?).to be true
        expect(interactor.message).to eq(:pin_code_must_not_blank)
      end
    end

    context 'when input pin code is not blank' do
      let(:input_pin_code) { '987654' }

      context 'and pin codes match' do
        it 'succeeds' do
          interactor = SpreeCmCommissioner::ConfirmPinCodeChecker.call(user_pin_code: user_confirm_pin_code, input_pin_code: input_pin_code)
          expect(interactor.success?).to be true
        end
      end

      context 'and pin codes do not match' do
        let(:input_pin_code) { '123456' }

        it 'fails with an invalid_pin_code message' do
          interactor = SpreeCmCommissioner::ConfirmPinCodeChecker.call(user_pin_code: user_confirm_pin_code, input_pin_code: input_pin_code)
          expect(interactor.failure?).to be true
          expect(interactor.message).to eq(:invalid_pin_code)
        end
      end
    end
  end
end
