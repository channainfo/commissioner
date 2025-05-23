require 'spec_helper'

RSpec.describe SpreeCmCommissioner::PinCodeSender do
  describe '#call' do
    context 'when contact_type is email' do
      it 'send code to the given email' do
        code = create(:pin_code, contact: 'admin@gmail.com', contact_type: :email, type: 'SpreeCmCommissioner::PinCodeLogin')

        expect(SpreeCmCommissioner::PinCodeMailer).to receive(:send_pin_code).with(code.id, code.readable_type, nil).and_call_original

        SpreeCmCommissioner::PinCodeSender.call(pin_code: code)
      end
    end

    context 'contact type is mobile number' do
      it 'send sms' do
        pin_code = create(:pin_code, contact: '087420441', contact_type: :phone_number,
          type: 'SpreeCmCommissioner::PinCodeLogin')

          options = {
            from: 'Spree Test Store',
            to: pin_code.contact,
            body: "#{pin_code.code} is your #{pin_code.readable_type}"
          }

          expect(SpreeCmCommissioner::SmsPinCodeJob).to receive(:perform_later).with(options)

          SpreeCmCommissioner::PinCodeSender.call(pin_code: pin_code)
        end
      end

      context 'when pin code is nil' do
        it 'return error' do
          send_pin_code_context = SpreeCmCommissioner::PinCodeSender.call(pin_code: nil)

          expect(send_pin_code_context.success?).to eq false
          expect(send_pin_code_context.message).to eq I18n.t('pincode_sender.pincode.blank')
        end
      end
    end
  end
