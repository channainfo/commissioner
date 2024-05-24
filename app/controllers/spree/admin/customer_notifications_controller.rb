module Spree
  module Admin
    class CustomerNotificationsController < Spree::Admin::ResourceController
      def index
        @notifications = SpreeCmCommissioner::CustomerNotification.all
      end

      def model_class
        SpreeCmCommissioner::CustomerNotification
      end

      def object_name
        'spree_cm_commissioner_customer_notification'
      end

      def collection_url(options = {})
        admin_customer_notifications_url(options)
      end

      private

      def customer_notification_params
        params.require(:customer_notification).permit(
          :title, :body, :url, :notification_type, :payload, :excerpt, :started_at, :sent_at, :send_all,
          :match_policy, :preferences, taxon_ids: []
        )
      end
    end
  end
end
