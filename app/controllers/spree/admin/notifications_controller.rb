module Spree
  module Admin
    class NotificationsController < Spree::Admin::ResourceController
      before_action :load_customer_notification

      def index
        @notifications = @customer_notification.notifications
                                               .page(params[:page])
                                               .per(params[:per_page])
      end

      private

      def load_customer_notification
        @customer_notification ||= SpreeCmCommissioner::CustomerNotification.find_by(id: params[:customer_notification_id])
      end

      def model_class
        SpreeCmCommissioner::Notification
      end

      def object_name
        'spree_cm_commissioner_notification'
      end

      def collection_url
        admin_customer_notification_notifications_url
      end
    end
  end
end
