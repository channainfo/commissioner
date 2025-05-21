module  SpreeCmCommissioner
  class ProductEventIdToChildrenSyncer < BaseInteractor
    delegate :product, to: :context

    # skip validation & callback like checking stock, etc.
    def call
      event_id = product.event_id

      # rubocop:disable Rails/SkipsModelValidations
      product.line_items.find_each { |line_item| line_item.update_columns(event_id: event_id) }
      product.guests.find_each { |guest| guest.update_columns(event_id: event_id) }
      # rubocop:enable Rails/SkipsModelValidations
    end
  end
end
