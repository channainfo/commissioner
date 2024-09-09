module SpreeCmCommissioner
  class CustomerNotificationSenderJob < ApplicationJob
    def perform(customer_notification_id, user_ids = nil)
      customer_notification = SpreeCmCommissioner::CustomerNotification.find(customer_notification_id)
      SpreeCmCommissioner::CustomerNotificationSender.call(customer_notification: customer_notification, user_ids: user_ids)
    end
  end
end
