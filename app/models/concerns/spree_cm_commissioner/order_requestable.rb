module SpreeCmCommissioner
  module OrderRequestable
    extend ActiveSupport::Concern

    included do
      after_commit  :update_and_notify_if_confirmation_needed

      state_machine :request_state, initial: nil, use_transactions: false do
        event :request do
          transition from: nil, to: :requested
        end
        event :accept do
          transition from: :requested, to: :accepted
        end
        after_transition to: :accepted, do: :send_order_accepted_notification

        event :reject do
          transition from: :requested, to: :rejected
        end
        after_transition to: :rejected, do: :send_order_rejected_notification
      end

      def send_order_requested_notification
        SpreeCmCommissioner::OrderRequestedNotificationSender.call(order: self)
      end

      def send_order_accepted_notification
        SpreeCmCommissioner::OrderAcceptedNotificationSender.call(order: self)
      end

      def send_order_rejected_notification
        SpreeCmCommissioner::OrderRejectedNotificationSender.call(order: self)
      end

      def state_changed_to_complete?
        saved_change_to_state? && state == 'complete'
      end

      def requested_state?
        request_state == 'requested'
      end

      def need_confirmation?
        line_items.any?(&:need_confirmation)
      end

      def update_request_state_to_requested
        return unless request_state != 'requested'

        request!
        send_order_requested_notification
      end

      def update_and_notify_if_confirmation_needed
        return unless need_confirmation? && state_changed_to_complete?

        update_request_state_to_requested
      end
    end
  end
end
