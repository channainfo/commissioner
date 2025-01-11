module SpreeCmCommissioner
  class TelegramDebugPinCodeSenderJob < ApplicationUniqueJob
    def perform(pin_code_id)
      pin_code = SpreeCmCommissioner::PinCode.find(pin_code_id)

      SpreeCmCommissioner::TelegramDebugPinCodeSender.call(pin_code: pin_code)
    end
  end
end
