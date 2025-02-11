module SpreeCmCommissioner
  class OrderRejectedStateUpdater < BaseInteractor
    delegate :order, to: :context
    delegate :authorized_user, to: :context

    def call
      return context.fail!(message: 'error while update state') unless order.requested_state?

      update_request_state
      update_line_item_rejected_at_and_rejected_by
    end

    def update_request_state
      order.update(request_state: :rejected)
    end

    def update_line_item_rejected_at_and_rejected_by
      order.line_items.each do |line_item|
        line_item.update(
          rejected_at: Time.current,
          rejecter: authorized_user
        )
      end
    end
  end
end
