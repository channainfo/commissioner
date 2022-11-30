module Spree
  module Api
    module V2
      module Storefront
        class UserRegistrationWithSocialsController < Spree::Api::V2::BaseController
          def create
            user_context = SpreeCmCommissioner::UserRegistrationWithSocial.call(id_token: params[:id_token])

            if user_context.success?
              token_context = SpreeCmCommissioner::OauthTokenGenerator.call(
                application: doorkeeper_token.application, 
                resource_owner: user_context.user
              )
              render json: token_context.token_response
            else
              render_error_payload(user_context.message)
            end
          end
        end
      end
    end
  end
end