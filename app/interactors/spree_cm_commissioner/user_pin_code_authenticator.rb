module SpreeCmCommissioner
  class UserPinCodeAuthenticator < BaseInteractor
    def call
      validate_pin_code!
      register_user!
      mark_pin_code_expired!
    end

    def sanitize_contact
      context.email = nil if context.phone_number.present?
    end

    def validate_pin_code!
      options = context.to_h.slice(:email, :phone_number)

      options[:pin_code] = context.pin_code
      options[:pin_code_token] = context.pin_code_token
      options[:id] = context.pin_code_token
      options[:type] = 'SpreeCmCommissioner::PinCodeRegistration'
      options[:long_life_pin_code] = true

      pin_code_checker = SpreeCmCommissioner::PinCodeChecker.call(options)

      return if pin_code_checker.success?

      context.fail!(message: pin_code_checker.message)
    end

    def register_user!
      sanitize_contact
      fields = %i[first_name last_name password password_confirmation phone_number email gender dob]
      create_options = context.to_h.slice(*fields)

      user = Spree::User.new(create_options)
      user.confirmed_at = Time.zone.now

      if user.save
        context.user = user
      else
        context.fail!(message: user.errors.full_messages.join('\n'))
      end
    end

    def mark_pin_code_expired!
      SpreeCmCommissioner::PinCode.mark_expired!(context.pin_code_token)
    end
  end
end
