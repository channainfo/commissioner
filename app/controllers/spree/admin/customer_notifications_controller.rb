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

      def notification_sender
        customer_notification = SpreeCmCommissioner::CustomerNotification.find(params[:notification_id])
        user_ids = params[:user_ids] # This can be nil or an array of user ids

        if params[:send_all] == 'true'
          SpreeCmCommissioner::CustomerNotificationSenderJob.perform_later(customer_notification.id)
          redirect_to admin_customer_notifications_path, notice: I18n.t('notification.send_all_in_progress')
        else
          SpreeCmCommissioner::CustomerNotificationSenderJob.perform_later(customer_notification.id, user_ids)
          redirect_to admin_customer_notifications_path, notice: I18n.t('notification.send_specific_in_progress')
        end
      rescue StandardError => e
        redirect_to admin_customer_notifications_path, alert: I18n.t('notification.error', error_message: e.message)
      end
    end
  end
end
