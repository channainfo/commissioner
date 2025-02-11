module SpreeCmCommissioner
  class AllNotificationReader < NotificationBaseReader
    private

    def validation!
      context.fail!(message: 'User not found') if user.nil?
    end

    def mark_as_read!
      unread_notifications.mark_as_read!
    end

    def decrement_user_unread_notification_count!
      user.update!(unread_notification_count: 0)
    end

    def unread_notifications
      @unread_notifications ||= user.notifications.unread
    end
  end
end
