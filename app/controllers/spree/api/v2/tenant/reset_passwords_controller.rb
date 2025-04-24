module Spree
  module Api
    module V2
      module Tenant
        class ResetPasswordsController < BaseController
          def update
            context = SpreeCmCommissioner::UserForgottenPasswordUpdater.call(update_params)

            if context.success?
              render_serialized_payload { serialize_resource(context.user) }
            else
              render_error_payload(context.message)
            end
          end

          def resource_serializer
            Spree::V2::Tenant::ResetPasswordSerializer
          end

          def update_params
            params.permit(
              :email,
              :phone_number,
              :country_code,
              :pin_code,
              :pin_code_token,
              :password,
              :password_confirmation
            )
          end
        end
      end
    end
  end
end
