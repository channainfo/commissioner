module Spree
  module Api
    module V2
      module Tenant
        class PinCodeCheckersController < BaseController
          def update
            context = SpreeCmCommissioner::PinCodeChecker.call(pin_code_attrs)
            if context.success?
              render_serialized_payload { { status: 'ok' } }
            else
              render_error_payload(context.message, 400)
            end
          end

          private

          def pin_code_attrs
            results = params.slice(:phone_number, :email, :token, :pin_code, :pin_code_token, :type)
            results[:long_life_pin_code] = true
            results
          end
        end
      end
    end
  end
end
