module SpreeCmCommissioner
  class OrderAcceptedStateUpdater < BaseInteractor
    delegate :order, to: :context
    delegate :authorized_user, to: :context

    def call
      return context.fail!(message: 'error while update state') unless order.requested_state?

      update_request_state
      update_line_item_accepted_at_and_accepted_by
    end

    def update_request_state
      order.update(request_state: :accepted)
    end

    def update_line_item_accepted_at_and_accepted_by
      order.line_items.each do |line_item|
        line_item.update(
          accepted_at: Time.current,
          accepted_by: authorized_user
        )
      end
    end
  end
end
