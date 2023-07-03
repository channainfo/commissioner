module SpreeCmCommissioner
  class NotificationReader < BaseInteractor
    delegate :notification, to: :context

    def call
      notification.mark_as_read! if notification.unread?
    end
  end
end
