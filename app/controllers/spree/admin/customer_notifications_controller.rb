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
        user_ids = params[:user_ids] || []
        customer_notification = SpreeCmCommissioner::CustomerNotification.find(params[:notification_id])
        context = { customer_notification: customer_notification, user_ids: user_ids }
        begin
          response = SpreeCmCommissioner::CustomerNotificationSender.call(context)
          redirect_to admin_customer_notifications_path, notice: I18n.t('notification.send_test_success') if response.success?
        rescue StandardError => e
          redirect_to admin_customer_notifications_path, alert: e.message
        end
      end
    end
  end
end
