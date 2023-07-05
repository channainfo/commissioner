module SpreeCmCommissioner
  class CustomerNotificationSenderJob < ApplicationJob
    def perform(customer_notification_id)
      customer_notification = SpreeCmCommissioner::CustomerNotification.find(customer_notification_id)
      SpreeCmCommissioner::CustomerNotificationSender.call(customer_notification: customer_notification)
    end
  end
end
