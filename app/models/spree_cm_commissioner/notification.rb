module SpreeCmCommissioner
  class Notification < SpreeCmCommissioner::Base
    include Noticed::Model

    scope :request_notifications, lambda {
      select('DISTINCT ON (notificable_id) *')
        .where(type: %w[order_requested_notification order_rejected_notification order_accepted_notification], read_at: nil)
        .order('notificable_id, created_at DESC')
    }

    scope :user_notifications, lambda {
      where(
        type: %w[order_complete_notification customer_notification]
      )
    }

    scope :unread_notifications, lambda {
      where(
        read_at: nil
      )
    }

    belongs_to :recipient, polymorphic: true
    belongs_to :notificable, polymorphic: true

    after_create_commit :increment_user_unread_notification_count

    private

    def increment_user_unread_notification_count
      recipient.update(unread_notification_count: recipient.unread_notification_count + 1)
      consolidate_unread_count_async
    end

    def consolidate_unread_count_async
      SpreeCmCommissioner::UserUnreadNotificationCountJob.perform_later(recipient_id)
    end
  end
end
