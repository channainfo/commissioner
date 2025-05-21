module SpreeCmCommissioner
  class EventLineItemsDateSyncer < BaseInteractor
    delegate :event, to: :context

    def call
      return unless event.event?
      return unless event.depth == 1

      event.event_line_items.includes(:variant).find_each do |line_item|
        new_from = line_item.variant.start_date_time || event.from_date
        new_to = line_item.variant.end_date_time || event.to_date

        # Update could be failed here if case line item does not allowed to change or no longer available.
        # We can ignore this line item in this case.
        line_item.update(from_date: new_from, to_date: new_to) if line_item.from_date != new_from || line_item.to_date != new_to
      end
    end
  end
end
