module SpreeCmCommissioner
  class CustomerNotificationCronExecutor < BaseInteractor
    def call
      customer_notifications.find_each do |customer_notification|
        enqueue_customer_notification_alert(customer_notification)
      end
    end

    def customer_notifications
      SpreeCmCommissioner::CustomerNotification.scheduled_items
    end

    def enqueue_customer_notification_alert(customer_notification)
      SpreeCmCommissioner::CustomerNotificationSenderJob.perform_later(customer_notification.id)
    end
  end
end
