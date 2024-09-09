module Spree
  module Api
    module V2
      module Storefront
        class OrderRequestNotificationsController < NotificationsController
          before_action :require_spree_current_user

          def collection
            spree_current_user.notifications.request_notifications
          end

          def serialize_collection(collection)
            options_data = collection_options(collection).merge(params: serializer_params)
            options_data[:meta][:unread_count] = spree_current_user.notifications.request_notifications.where(read_at: nil).size

            collection_serializer.new(
              collection,
              options_data
            ).serializable_hash
          end
        end
      end
    end
  end
end
