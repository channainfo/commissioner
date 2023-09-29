module SpreeCmCommissioner
  class UserForgottenPasswordUpdater < BaseInteractor
    # :email, :phone_number, :country_code :pin_code, :pin_code_token, :password, :password_confirmation

    def call
      find_user_by_login!
      validate_pin_code!
      reset_password!
    end

    def phone_number
      context.phone_number&.strip
    end

    def email
      context.email&.strip
    end

    def find_user_by_login!
      login = phone_number || email

      context.user = Spree.user_class.find_user_by_login(login)
      context.fail!(message: I18n.t('account_checker.verify.not_exist', login: login)) if context.user.blank?
    end

    def validate_pin_code!
      options = context.to_h.slice(:email, :phone_number, :country_code, :pin_code, :pin_code_token)
      options[:type] = 'SpreeCmCommissioner::PinCodeForgetPassword'
      options[:long_life_pin_code] = true

      pin_code_checker = SpreeCmCommissioner::PinCodeChecker.call(options)
      return if pin_code_checker.success?

      context.fail!(message: pin_code_checker.message)
    end

    def reset_password!
      ok = context.user.reset_password(context.password, context.password_confirmation)

      if ok
        SpreeCmCommissioner::PinCode.mark_expired!(context.pin_code_token)
      else
        context.fail!(message: context.user.errors.full_messages.join("\n").presence)
      end
    end
  end
end
