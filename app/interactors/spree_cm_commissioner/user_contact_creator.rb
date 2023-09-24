module SpreeCmCommissioner
  class UserContactCreator < BaseInteractor
    # :email, :phone_number, :pin_code, :pin_code_token, to: :context
    # create a new user contact
    def call
      sanitize_contact
      validate_pin_code!
      create_user_contact!
    end

    private

    def validate_pin_code!
      options = context.to_h.slice(:email, :phone_number, :pin_code, :pin_code_token)
      options[:type] = 'SpreeCmCommissioner::PinCodeContactCreate'
      options[:long_life_pin_code] = true

      pin_code_checker = SpreeCmCommissioner::PinCodeChecker.call(options)

      return if pin_code_checker.success?

      context.fail!(message: pin_code_checker.message)
    end

    def create_user_contact!
      ok = context.user.create(create_options)

      if ok
        SpreeCmCommissioner::PinCode.mark_expired!(context.pin_code_token)
      else
        field = context.email.present? ? 'email' : 'phone_number'
        context.fail!(message: I18n.t("user_create_contact.#{field}_is_already_used"))
      end
    end

    def create_options
      # don't use context.email.present? since user might use validate pincode email
      # however try to create phone number and viceversa
      if context.email.present?
        { email: context.email }
      else
        { phone_number: context.phone_number }
      end
    end

    def sanitize_contact
      context.email = nil if context.phone_number.present?
    end
  end
end