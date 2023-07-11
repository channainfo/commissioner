require 'spec_helper'

RSpec.describe SpreeCmCommissioner::PinCodeChecker do
  let!(:pin_code) do
    create(:pin_code, contact: '0123456789', contact_type: :phone_number, expires_in: 900,
                               type: 'SpreeCmCommissioner::PinCodeLogin')
  end

  context 'when the given info is matched with the pin code' do
    it 'return ok' do
      options = {
        id: pin_code.token,
        phone_number: '0123456789',
        code: pin_code.code,
        type: 'SpreeCmCommissioner::PinCodeLogin',
        long_life_pin_code: true
      }
      checker_context = SpreeCmCommissioner::PinCodeChecker.call(options)
      expect(checker_context.success?).to eq true
    end
  end

  context 'when the given type is not correct' do
    it 'return not_found' do
      options = {
        id: pin_code.token ,
        phone_number: '0123456789',
        code: pin_code.code,
        type: 'SpreeCmCommissioner::PinCodeRegistration',
        long_life_pin_code: true
      }

      checker_context = SpreeCmCommissioner::PinCodeChecker.call(options)

      expect(checker_context.success?).to eq false
      expect(checker_context.message).to eq I18n.t('pincode_checker.error_type.not_found')
    end
  end

  context 'when pin code is expired' do
    it 'return expired' do
      options = {
        id: pin_code.token,
        phone_number: '0123456789',
        code: pin_code.code,
        type: 'SpreeCmCommissioner::PinCodeLogin',
        long_life_pin_code: true
      }

      pin_code.update(expired_at: 1.day.ago)
      checker_context = SpreeCmCommissioner::PinCodeChecker.call(options)

      expect(checker_context.success?).to eq false
      expect(checker_context.message).to eq I18n.t('pincode_checker.error_type.expired')
    end
  end

  context 'when pin code reach max attempt allowed (3 times)' do
    it 'return reached_max_attempt' do
      options = {
        id: pin_code.token,
        phone_number: '0123456789',
        code: pin_code.code,
        type: 'SpreeCmCommissioner::PinCodeLogin',
        long_life_pin_code: true
      }
      pin_code.number_of_attempt = 3
      pin_code.save
      pin_code.reload

      checker_context = SpreeCmCommissioner::PinCodeChecker.call(options)

      expect(checker_context.success?).to eq false
      expect(checker_context.message).to eq I18n.t('pincode_checker.error_type.reached_max_attempt')
    end
  end

  context 'when the given code is not matched' do
    it 'return not_match' do
      options = {
        id: pin_code.token,
        phone_number: '0123456789',
        code: '000001',
        type: 'SpreeCmCommissioner::PinCodeLogin',
        long_life_pin_code: true
      }
      checker_context = SpreeCmCommissioner::PinCodeChecker.call(options)

      expect(checker_context.success?).to eq false
      expect(checker_context.message).to eq I18n.t('pincode_checker.error_type.not_match')
    end
  end
end
