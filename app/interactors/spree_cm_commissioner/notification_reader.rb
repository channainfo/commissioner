module SpreeCmCommissioner
  class NotificationReader < BaseInteractor
    delegate :id, to: :context

    def call
      notification = SpreeCmCommissioner::Notification.find(id)
      return context.fail!(error_message: 'Notification not found') if notification.nil?

      notification.mark_as_read! if notification.unread?
    end
  end
end
