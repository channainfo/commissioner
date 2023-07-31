module SpreeCmCommissioner
  class PasswordChanger < BaseInteractor
    def call
      validate_password!
      change_password!
    end

    private

    def validate_password!
      valid = context.user.valid_for_authentication? { context.user.valid_password?(context.current_password) }
      context.fail!(message: I18n.t('authenticator.incorrect_password')) unless valid
    end

    def change_password!
      context.user.password = context.password
      context.user.password_confirmation = context.password_confirmation

      return if context.user.save

      context.fail!(message: context.user.errors.full_messages.join("\n"))
    end
  end
end
