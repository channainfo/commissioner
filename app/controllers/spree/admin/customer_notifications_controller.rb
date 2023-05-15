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
    end
  end
end
