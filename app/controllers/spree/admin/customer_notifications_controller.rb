module Spree
  module Admin
    class CustomerNotificationsController < Spree::Admin::ResourceController
      def index
        @users = Spree::User.where(id: SpreeCmCommissioner::DeviceToken.where.not(registration_token: nil).select(:user_id))
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

      def send_test
        ## in progress
        redirect_to admin_customer_notifications_path, notice: I18n.t('notification.send_test_success')
      end
    end
  end
end
