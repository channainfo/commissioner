module SpreeCmCommissioner
  class PinCodeMailer < Spree::BaseMailer
    def send_pin_code(pin_code_id, action)
      @pin_code = SpreeCmCommissioner::PinCode.find(pin_code_id)

      return unless @pin_code.email?

      subject = "#{Spree::Store.default.name} #{action.titlecase}"

      mail(from: from_address, to: @pin_code.contact, subject: subject)
    end
  end
end
