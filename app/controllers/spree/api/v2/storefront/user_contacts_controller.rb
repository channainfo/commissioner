module Spree
  module Api
    module V2
      module Storefront
        class UserContactsController < Spree::Api::V2::ResourceController
          def update
            options = user_with_pin_code_params

            generator_context = ::SpreeCmCommissioner::UserContactUpdater.call(options)

            if generator_context.success?
              # head :ok
              render_serialized_payload { serialize_resource(generator_context.user) }
            else
              render_error_payload(generator_context.message)
            end
          end

          private

          def user_with_pin_code_params
            results = params.permit(:pin_code, :pin_code_token, :email, :phone_number)
            results[:user] = spree_current_user
            results.to_h
          end

          def resource_serializer
            ::SpreeCmCommissioner::V2::Storefront::UserContactSerializer
          end
        end
      end
    end
  end
end
