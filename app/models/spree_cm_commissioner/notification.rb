module SpreeCmCommissioner
  class Notification < SpreeCmCommissioner::Base
    include Noticed::Model

    scope :request_notifications, lambda {
      where(
        type: %w[order_requested_notification order_rejected_notification order_accepted_notification],
        read_at: nil
      ).newest_first
    }

    scope :user_notifications, lambda {
      where(
        type: %w[order_complete_notification customer_notification]
      )
    }

    belongs_to :recipient, polymorphic: true
    belongs_to :notificable, polymorphic: true
  end
end
