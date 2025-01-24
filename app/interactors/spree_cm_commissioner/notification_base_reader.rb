module SpreeCmCommissioner
  class NotificationBaseReader < BaseInteractor
    delegate :id, :user, to: :context

    def call
      validation!

      ActiveRecord::Base.transaction do
        mark_as_read!
        decrement_user_unread_notification_count!
        consolidate_unread_count_async
      end
    end

    private

    def validation!
      raise NotImplementedError, 'Subclasses must implement this method'
    end

    def mark_as_read!
      raise NotImplementedError, 'Subclasses must implement this method'
    end

    def decrement_user_unread_notification_count!
      raise NotImplementedError, 'Subclasses must implement this method'
    end

    def consolidate_unread_count_async
      SpreeCmCommissioner::UserUnreadNotificationCountJob.perform_later(user.id)
    end
  end
end
