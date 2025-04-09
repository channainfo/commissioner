module Spree
  module Api
    module V2
      module Tenant
        class CustomerNotificationsController < BaseController
          before_action :require_spree_current_user

          def show
            customer_notification = SpreeCmCommissioner::CustomerNotification.find(params[:id])
            render_serialized_payload { serialize_resource(customer_notification) }
          end

          def resource_serializer
            Spree::V2::Tenant::CustomerNotificationSerializer
          end
        end
      end
    end
  end
end
