module Spree
  module Api
    module V2
      module Tenant
        class UserDeviceTokensController < BaseController
          before_action :require_spree_current_user

          def create
            options = filter_params.merge(user: spree_current_user)
            context = SpreeCmCommissioner::UserDeviceTokenRegister.call(options)

            if context.success?
              render_serialized_payload { serialize_resource(context.device_token) }
            else
              render_error_payload(context.message)
            end
          end

          def destroy
            options = {
              user: spree_current_user,
              registration_token: params[:id]
            }

            context = SpreeCmCommissioner::UserDeviceTokenDeregister.call(options)

            if context.success?
              render json: { message: 'Device token deleted successfully' }, status: :ok
            else
              render_error_payload(context.error)
            end
          end

          def resource_serializer
            Spree::V2::Tenant::UserDeviceTokenSerializer
          end

          def filter_params
            {
              registration_token: params[:registration_token],
              device_type: params[:device_type],
              client_version: app_version,
              client_name: app_name
            }
          end
        end
      end
    end
  end
end
