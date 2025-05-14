module SpreeCmCommissioner
  class TelegramDebugPinCodeSenderJob < ApplicationUniqueJob
    include SpreeCmCommissioner::PinCodeSenderHelper

    def perform(options)
      pin_code = SpreeCmCommissioner::PinCode.find(options[:pin_code_id])
      tenant = SpreeCmCommissioner::Tenant.find_by(id: options[:tenant_id])
      error_message = options[:error_message]

      name = sender_name(tenant)

      SpreeCmCommissioner::TelegramDebugPinCodeSender.call(
        pin_code: pin_code,
        name: name,
        error_message: error_message
      )
    end
  end
end
