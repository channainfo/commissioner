module SpreeCmCommissioner
  class CustomerNotificationSender < BaseInteractor
    delegate :user_ids, :customer_notification, to: :context

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
      if user_ids.present?
        send_to_specific_users(user_ids)
      elsif user_ids.blank?
        send_to_all_users_now
      else
        send_to_all_users
      end
    end

    def send_to_specific_users(user_ids)
      users = Spree::User.push_notificable.where(id: user_ids)
      users.find_each do |user|
        deliver_notification_to_user(user)
      end
    end

    def send_to_all_users
      users_not_received_notifications.find_each do |user|
        deliver_notification_to_user(user)
      end
    end

    def send_to_all_users_now
      end_users.find_each do |user|
        deliver_notification_to_user(user)
      end
    end

    def deliver_notification_to_user(user)
      SpreeCmCommissioner::CustomerContentNotificationCreator.call(
        user_id: user.id,
        customer_notification_id: customer_notification.id
      )
    end

    def users_not_received_notifications
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
