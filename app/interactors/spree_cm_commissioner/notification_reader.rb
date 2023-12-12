module SpreeCmCommissioner
  class NotificationReader < BaseInteractor
    delegate :id, :user, to: :context

    def call
      read_specific_notification if id.present?
      read_all_user_unread_notifications if user.present?
    end

    def read_specific_notification
      notification = SpreeCmCommissioner::Notification.find_by(id: id)
      return context.fail!(error_message: 'Notification not found') if notification.nil?

      notification.mark_as_read! if notification.unread?
    end

    def read_all_user_unread_notifications
      user.notifications.unread_notifications.mark_as_read!
    end
  end
end
