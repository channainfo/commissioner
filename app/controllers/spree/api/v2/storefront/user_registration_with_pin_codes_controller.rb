module Spree
  module Api
    module V2
      module Storefront
        class UserRegistrationWithPinCodesController < Spree::Api::V2::ResourceController
          def create
            options = user_with_pin_code_params
            context = SpreeCmCommissioner::UserPinCodeAuthenticator.call(options)

            if context.success?

              token_context = SpreeCmCommissioner::OauthTokenGenerator.call(
                application: doorkeeper_token.application,
                resource_owner: context.user
              )

              render json: token_context.token_response
            else
              render_error_payload(context.message)
            end
          end

          private

          def user_with_pin_code_params
            results = params.permit(
              :pin_code, :pin_code_token, :email, :phone_number, :first_name, :last_name,
              :password, :password_confirmation, :gender, :dob
            )
            results.to_h
          end
        end
      end
    end
  end
end
