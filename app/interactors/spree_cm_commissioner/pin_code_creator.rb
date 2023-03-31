module SpreeCmCommissioner
  class PinCodeCreator < BaseInteractor
    def call
      set_contact

      attrs = { contact: context.contact, contact_type: context.contact_type, type: context.type }
      new_pin_code = SpreeCmCommissioner::PinCode.new(attrs)

      if new_pin_code.save
        context.pin_code = new_pin_code
      else
        context.fail!(message: new_pin_code.errors.full_messages.join(', '))
      end
    end

    private

    def set_contact
      if context.phone_number.present?
        country_code = context.country_code || 'kh'
        phone_parser = Phonelib.parse(context.phone_number, country_code)
        context.fail!(message: I18n.t('pincode_creator.invalid_phone_number')) unless phone_parser.valid?

        context.contact = phone_parser.international.gsub!(/[() -]/, '')
        context.contact_type = :phone_number
      else
        context.fail!(message: I18n.t('pincode_creator.invalid_email_address')) if context.email !~ Devise.email_regexp
        context.contact = context.email
        context.contact_type = :email
      end
    end
  end
end
