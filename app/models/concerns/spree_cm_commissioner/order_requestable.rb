module SpreeCmCommissioner
  module OrderRequestable
    extend ActiveSupport::Concern

    included do
      state_machine.after_transition to: :complete, do: :update_and_notify_if_confirmation_needed

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

      def requested_state?
        request_state == 'requested'
      end

      def need_confirmation?
        line_items.any?(&:need_confirmation)
      end

      def update_request_state_to_requested
        return unless request_state != 'requested'

        request!
      end

      def update_and_notify_if_confirmation_needed
        return unless need_confirmation?

        update_request_state_to_requested
        send_order_requested_notification
      end
    end
  end
end