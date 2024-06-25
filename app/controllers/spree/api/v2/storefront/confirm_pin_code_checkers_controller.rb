module Spree
  module Api
    module V2
      module Storefront
        class ConfirmPinCodeCheckersController < ::Spree::Api::V2::ResourceController
          before_action :require_spree_current_user

          def update
            context = SpreeCmCommissioner::ConfirmPinCodeChecker.call(
              input_pin_code: params[:pin_code],
              user_pin_code: spree_current_user.confirm_pin_code_digest
            )

            if context.success?
              render_serialized_payload { { status: 'ok' } }
            else
              render_error_payload(context.message, 400)
            end
          end
        end
      end
    end
  end
end
