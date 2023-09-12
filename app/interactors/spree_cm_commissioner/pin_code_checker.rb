module SpreeCmCommissioner
  class PinCodeChecker < BaseInteractor
    def call
      pin_coder = context.type.constantize
      options = context.to_h.slice(
        :pin_code_token,
        :pin_code,
        :email,
        :phone_number,
        :type,
        :long_life_pin_code,
        :user_validation_check,
        :country_code
      )

      @result = pin_coder.check?(options)

      return unless @result != 'ok'

      context.fail!(message: readable_result)
    end

    def readable_result
      I18n.t("pincode_checker.error_type.#{@result}")
    end
  end
end
