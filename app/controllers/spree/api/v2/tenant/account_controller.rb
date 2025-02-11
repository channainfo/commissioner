module Spree
  module Api
    module V2
      module Tenant
        class AccountController < BaseController
          before_action :require_spree_current_user, only: %i[show create]

          def show
            render_serialized_payload { serialize_resource(resource) }
          end

          def update
            spree_authorize! :update, spree_current_user
            result = update_service.call(user: spree_current_user, user_params: user_update_params)
            render_result(result)
          end

          private

          def resource
            spree_current_user
          end

          def resource_serializer
            Spree::V2::Tenant::UserSerializer
          end

          def model_class
            Spree.user_class
          end

          def update_service
            Spree::Api::Dependencies.storefront_account_update_service.constantize
          end

          def user_update_params
            params.require(:user).permit(permitted_user_attributes)
          end
        end
      end
    end
  end
end
