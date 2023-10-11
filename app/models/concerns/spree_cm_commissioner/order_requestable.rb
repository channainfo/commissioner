module SpreeCmCommissioner
  module OrderRequestable
    extend ActiveSupport::Concern

    included do
      state_machine.after_transition to: :complete do |order, _transition|
        order.notify_order_complete_app_notification_to_user
        order.request! if order.need_confirmation?
      end

      state_machine :request_state, initial: nil, use_transactions: false do
        event :request do
          transition from: nil, to: :requested
        end
        after_transition to: :requested, do: :send_order_requested_app_notification_to_user
        after_transition to: :requested, do: :send_order_requested_telegram_alert_store

        event :accept do
          transition from: :requested, to: :accepted
        end
        after_transition to: :accepted, do: :send_order_accepted_app_notification_to_user
        after_transition to: :accepted, do: :send_order_accepted_telegram_alert_to_store

        # call confirmation_delivered column directly since confirmation_delivered? is overrided
        after_transition to: :accepted, if: :confirmation_delivered, do: :deliver_order_confirmation_email

        event :reject do
          transition from: :requested, to: :rejected
        end
        after_transition to: :rejected, do: :send_order_rejected_app_notification_to_user
        after_transition to: :rejected, do: :send_order_rejected_telegram_alert_to_store

        after_transition do |order, transition|
          order.log_state_changes(
            old_state: transition.from,
            new_state: transition.to,
            state_name: :request
          )
        end
      end
    end

    # allow authorized user to accept all requested line items
    def accepted_by(user)
      transaction do
        accept!

        line_items.each do |line_item|
          line_item.accepted_by(user)
        end
      end
    end

    # can_accepted? already use by ransack/visitor.rb
    def can_accept_all?
      approved? && !accepted? && need_confirmation?
    end

    def can_alert_request_to_vendor?
      !accepted? && approved? && need_confirmation?
    end

    def requested_state?
      request_state == 'requested'
    end

    def need_confirmation?
      line_items.any?(&:need_confirmation)
    end

    def send_order_request_telegram_confirmation_alert_to_vendor; end

    def notify_order_complete_app_notification_to_user
      SpreeCmCommissioner::OrderCompleteNotificationSender.call(order: self)
    end

    def send_order_requested_app_notification_to_user
      SpreeCmCommissioner::OrderRequestedNotificationSender.call(order: self)
    end

    def send_order_accepted_app_notification_to_user
      SpreeCmCommissioner::OrderAcceptedNotificationSender.call(order: self)
    end

    def send_order_rejected_app_notification_to_user
      SpreeCmCommissioner::OrderRejectedNotificationSender.call(order: self)
    end

    def send_order_requested_telegram_alert_store; end
    def send_order_accepted_telegram_alert_to_store; end
    def send_order_rejected_telegram_alert_to_store; end
  end
end
