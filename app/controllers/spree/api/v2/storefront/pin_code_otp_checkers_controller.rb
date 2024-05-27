module Spree
  module Api
    module V2
      module Storefront
        class PinCodeOtpCheckersController < ::Spree::Api::V2::ResourceController
          def update
            options = otp_attrs
            options[:type] = 'SpreeCmCommissioner::PinCodeOtp'
            options[:long_life_pin_code] = true

            context = SpreeCmCommissioner::PinCodeChecker.call(options)
            if context.success?
              render_serialized_payload { { status: 'ok' } }
            else
              render_error_payload(context.message, 400)
            end
          end

          private

          def otp_attrs
            params.slice(:phone_number, :email, :token, :pin_code, :pin_code_token)
          end
        end
      end
    end
  end
end
