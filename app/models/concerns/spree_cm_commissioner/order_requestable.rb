module SpreeCmCommissioner
  module OrderRequestable
    extend ActiveSupport::Concern

    included do
      after_save :update_request_state_to_requested, if: :need_confirmation?
      after_commit :send_order_requested_notification, if: :request_order?

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

      def update_request_state_to_requested
        request!
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

      def request_order?
        need_confirmation? && state_changed_to_complete?
      end

      def state_changed_to_complete?
        saved_change_to_state? && state == 'complete'
      end

      def need_confirmation?
        line_items.any?(&:need_confirmation?)
      end
    end
  end
end
