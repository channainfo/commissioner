module SpreeCmCommissioner
  class ConfirmPinCodeChecker < BaseInteractor
    delegate :input_pin_code, :user_pin_code, to: :context

    def call
      context.fail!(message: :pin_code_must_not_blank) if input_pin_code.blank?

      validate_pin_code!
    end

    private

    def validate_pin_code!
      context.fail!(message: :invalid_pin_code) unless BCrypt::Password.new(user_pin_code) == input_pin_code
    end
  end
end
