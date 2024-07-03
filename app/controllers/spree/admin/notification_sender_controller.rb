module Spree
  module Admin
    class NotificationSenderController < Spree::Admin::BaseController
      def create
        customer_notification_id = params[:notification_id]
        user_ids = params[:send_all] == 'true' ? nil : params[:user_ids]

        SpreeCmCommissioner::CustomerNotificationSenderJob.perform_later(customer_notification_id, user_ids)

        redirect_to admin_customer_notifications_path
      end
    end
  end
end
