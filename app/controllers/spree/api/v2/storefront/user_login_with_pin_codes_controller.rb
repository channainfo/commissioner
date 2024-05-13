module Spree
  module Api
    module V2
      module Storefront
        class UserLoginWithPinCodesController < Spree::Api::V2::ResourceController
          before_action :validate_token_client!

          def validate_token_client!
            raise Doorkeeper::Errors::DoorkeeperError if doorkeeper_token&.application.nil?
          end

          def create
            options = user_login_with_pin_code_params.to_h
            options[:type] = 'SpreeCmCommissioner::PinCodeLogin'
            options[:long_life_pin_code] = true

            pin_code_checker = SpreeCmCommissioner::PinCodeChecker.call(options)

            if pin_code_checker.success?
              user = Spree::User.find_by(email: options[:email])

              token_context = SpreeCmCommissioner::OauthTokenGenerator.call(
                application: doorkeeper_token.application,
                resource_owner: user
              )

              render json: token_context.token_response
            else
              render_error_payload(context.message)
            end
          end

          private

          def user_login_with_pin_code_params
            params.permit(:pin_code, :pin_code_token, :email, :phone_number)
          end
        end
      end
    end
  end
end
