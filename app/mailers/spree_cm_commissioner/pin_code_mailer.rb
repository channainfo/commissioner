module SpreeCmCommissioner
  class PinCodeMailer < Spree::BaseMailer
    include SpreeCmCommissioner::PinCodeSenderHelper

    def send_pin_code(pin_code_id, action, tenant)
      @pin_code = SpreeCmCommissioner::PinCode.find(pin_code_id)
      @tenant = tenant

      @sender_name = sender_name(tenant)
      @sender_email = sender_email(tenant)
      @logo_path = logo_url(tenant)

      return unless @pin_code.email?

      subject = "#{@sender_name} #{action.titlecase}"

      mail(from: @sender_email, to: @pin_code.contact, subject: subject)
    end
  end
end
