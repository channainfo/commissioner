module SpreeCmCommissioner
  class TwoFactorPinCodeGenerator < BaseInteractor
    delegate :user, to: :context
    def call
      generate_pin_code(user)
    end

    private

    def generate_pin_code(user)
      attrs = pin_code_attrs(user)
      attrs[:type] = 'SpreeCmCommissioner::PinCodeLogin'

      SpreeCmCommissioner::PinCodeGenerator.call(attrs)
    end

    def pin_code_attrs(user)
      user.slice(:phone_number, :email)
    end
  end
end
