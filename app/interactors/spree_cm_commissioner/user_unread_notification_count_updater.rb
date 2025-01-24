module SpreeCmCommissioner
  class UserUnreadNotificationCountUpdater < BaseInteractor
    delegate :user, to: :context

    def call
      update_unread_notification_count!
    end

    private

    def update_unread_notification_count!
      user.update!(unread_notification_count: user.notifications.unread.count)

      context.user = user
    end
  end
end
