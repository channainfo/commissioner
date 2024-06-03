module Spree
  module Admin
    class NotificationUsersController < Spree::Admin::BaseController
      def index
        notification = SpreeCmCommissioner::CustomerNotification.find(params[:customer_notification_id])
        users_with_device_token = fetch_users_with_device_token(notification)

        render json: users_with_device_token.as_json(only: %i[id], methods: %i[display_name])
      end

      private

      def fetch_users_with_device_token(notification)
        if notification.notification_taxons.present?
          users = users(notification.notification_taxons.pluck(:taxon_id))
          users.where(id: SpreeCmCommissioner::DeviceToken.where.not(registration_token: nil).select(:user_id))
        else
          Spree::User.where(id: SpreeCmCommissioner::DeviceToken.where.not(registration_token: nil).select(:user_id))
        end
      end

      def users(taxon_id)
        SpreeCmCommissioner::UsersByEventFetcherQuery.new(taxon_id).call
      end
    end
  end
end
