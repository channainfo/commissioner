module SpreeCmCommissioner
  module OrderRequestable
    extend ActiveSupport::Concern

    included do
      after_save :update_request_state_to_requested, if: :need_confirmation?

      state_machine :request_state, initial: nil, use_transactions: false do
        event :request do
          transition from: nil, to: :requested
        end
        event :accept do
          transition from: :requested, to: :accepted
        end
        event :reject do
          transition from: :requested, to: :rejected
        end
      end

      def update_request_state_to_requested
        request!
      end

      def requested_state?
        request_state == 'requested'
      end

      def need_confirmation?
        line_items.any?(&:need_confirmation?)
      end
    end
  end
end
