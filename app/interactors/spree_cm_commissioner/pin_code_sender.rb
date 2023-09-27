module  SpreeCmCommissioner
  class PinCodeSender < BaseInteractor
    def call
      context.fail!(message: I18n.t('pincode_sender.pincode.blank')) if context.pin_code.nil?

      if context.pin_code.phone_number?
        send_sms
      else
        send_email
      end

      send_telegram_debug_pin_code
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

    def send_telegram_debug_pin_code
      return unless ENV['PIN_CODE_DEBUG_NOTIFIY_TELEGRAM_ENABLE'] == 'yes'

      SpreeCmCommissioner::TelegramDebugPinCodeSenderJob.perform_later(context.pin_code.id)
    end
  end
end
