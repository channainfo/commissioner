module SpreeCmCommissioner
  class CustomerNotificationSender < BaseInteractor
    delegate :customer_notification, to: :context

    def call
      update_customer_notification_sent_at
      send_notification
    end

    def update_customer_notification_sent_at
      return if customer_notification.sent_at.present?

      customer_notification.sent_at = Time.current
      customer_notification.save
    end

    def send_notification
      send_to_all_users
    end

    def send_to_all_users
      users_not_recieved_notifications.find_each do |user|
        deliver_notification_to_user(user)
      end
    end

    def deliver_notification_to_user(user)
      SpreeCmCommissioner::CustomerContentNotificationCreatorJob.perform_later(
        user_id: user.id,
        customer_notification_id: customer_notification.ida
      )
    end

    def users_not_recieved_notifications
      end_users.where(cm_notifications: { id: nil })
    end

    def end_users
      Spree.user_class.end_users_push_notificable.joins(
        "LEFT JOIN cm_notifications ON (
          cm_notifications.recipient_id = spree_users.id
          AND cm_notifications.notificable_type = 'SpreeCmCommissioner::CustomerNotification'
          AND cm_notifications.notificable_id = #{customer_notification.id}
        )"
      )
    end
  end
end
