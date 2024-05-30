module Spree
  module Admin
    class NotificationSenderController < Spree::Admin::BaseController
      def create
        customer_notification = SpreeCmCommissioner::CustomerNotification.find(params[:notification_id])

        result = if params[:send_all] == 'true'
                   SpreeCmCommissioner::NotificationSendCreator.call(customer_notification: customer_notification, send_all: true)
                 else
                   SpreeCmCommissioner::NotificationSendCreator.call(customer_notification: customer_notification, user_ids: params[:user_ids])
                 end

        if result.success?
          redirect_to admin_customer_notifications_path, notice: I18n.t(result.notice_key)
        else
          redirect_to admin_customer_notifications_path, alert: I18n.t('notification.error', error_message: result.error)
        end
      end
    end
  end
end
