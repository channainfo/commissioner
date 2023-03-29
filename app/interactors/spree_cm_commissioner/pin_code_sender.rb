module  SpreeCmCommissioner
  class PinCodeSender < BaseInteractor
    def call
      context.fail!(message: I18n.t('pincode_sender.pincode.blank')) if context.pin_code.nil?

      if context.pin_code.phone_number?
        send_sms
      else
        send_email
      end
    end

    private

    def send_sms
      options = {
        to: context.pin_code.contact,
        body: I18n.t('pincode_sender.sms.body', code: context.pin_code.code, readable_type: context.pin_code.readable_type)
      }

      SpreeCmCommissioner::SmsPinCodeJob.perform_later(options)
    end

    def send_email
      SpreeCmCommissioner::PinCodeMailer.send_pin_code(context.pin_code.id, context.pin_code.readable_type).deliver_later
    end
  end
end
