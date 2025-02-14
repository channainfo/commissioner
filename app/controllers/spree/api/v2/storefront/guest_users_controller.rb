module Spree
  module Api
    module V2
      module Storefront
        class GuestUsersController < ::Spree::Api::V2::ResourceController
          before_action :validate_token_client!

          def validate_token_client!
            raise Doorkeeper::Errors::DoorkeeperError if doorkeeper_token&.application.nil?
          end

          def create
            context = SpreeCmCommissioner::GuestUserCreation.call

            if context.success?
              token_context = SpreeCmCommissioner::OauthTokenGenerator.call(
                application: doorkeeper_token.application,
                resource_owner: context.result
              )

              render json: token_context.token_response, status: :created
            else
              render_error_payload(context.message)
            end
          end
        end
      end
    end
  end
end
