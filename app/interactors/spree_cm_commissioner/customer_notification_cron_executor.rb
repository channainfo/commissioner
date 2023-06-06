module SpreeCmCommissioner
  class CustomerNotificationCronExecutor < BaseInteractor
    def call
      customer_notifications.find_each do |customer_notification|
        alert_customer_notification(customer_notification)
      end
    end

    def customer_notifications
      SpreeCmCommissioner::CustomerNotification.scheduled_items
    end

    def alert_customer_notification(customer_notification)
      update_customer_notification_sent_at(customer_notification)
      enqueue_customer_notification_alert(customer_notification)
    end

    def update_customer_marketing_notification_sent_at(customer_notification)
      customer_notification.sent_at = Time.current
      customer_notification.save
    end

    def enqueue_customer_notification_alert(customer_notification)
      SpreeCmCommissioner::CustomerNotificationSenderJob.perform_later(customer_notification.id)
    end
  end
end
