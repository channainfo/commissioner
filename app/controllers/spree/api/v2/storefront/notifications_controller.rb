module Spree
  module Api
    module V2
      module Storefront
        class NotificationsController < Spree::Api::V2::ResourceController
          before_action :require_spree_current_user

          def collection
            spree_current_user.notifications.newest_first.user_notifications
          end

          def serialize_collection(collection)
            options_data = collection_options(collection).merge(params: serializer_params)
            options_data[:meta][:unread_count] = collection.select(&:unread?).count

            collection_serializer.new(
              collection,
              options_data
            ).serializable_hash
          end

          def collection_serializer
            Spree::V2::Storefront::NotificationSerializer
          end

          def show
            notification = SpreeCmCommissioner::Notification.find(params[:id])

            render_serialized_payload { serialize_resource(notification) }
          end

          def mark_as_read
            result = SpreeCmCommissioner::NotificationReader.call(id: params[:id])

            return unless result.success?

            head :ok
          end

          def mark_all_as_read
            result = SpreeCmCommissioner::AllNotificationReader.call(user: spree_current_user)

            return unless result.success?

            head :ok
          end

          def resource_serializer
            Spree::V2::Storefront::NotificationSerializer
          end
        end
      end
    end
  end
end
