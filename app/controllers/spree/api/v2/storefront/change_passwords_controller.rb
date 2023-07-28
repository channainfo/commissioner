module Spree
  module Api
    module V2
      module Storefront
        class ChangePasswordsController < Spree::Api::V2::ResourceController
          before_action :require_spree_current_user

          def update
            context = SpreeCmCommissioner::PasswordChanger.call(change_password_params)

            if context.success?
              render_serialized_payload { serialize_resource(context.user) }
            else
              render_error_payload(context.message)
            end
          end

          def resource_serializer
            Spree::V2::Storefront::UserSerializer
          end

          def change_password_params
            result = params.permit(:current_password, :password, :password_confirmation)
            result[:user] = spree_current_user

            result.to_h
          end
        end
      end
    end
  end
end
