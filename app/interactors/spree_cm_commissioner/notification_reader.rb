module SpreeCmCommissioner
  class NotificationReader < NotificationBaseReader
    private

    def validation!
      context.fail!(message: 'Notification not found') if notification.nil?
    end

    def mark_as_read!
      notification.mark_as_read!
    end

    def decrement_user_unread_notification_count!
      user.update!(unread_notification_count: user.unread_notification_count - 1)
    end

    def user
      @user ||= notification.recipient
    end

    def notification
      @notification ||= SpreeCmCommissioner::Notification.find_by(id: id)
    end
  end
end
