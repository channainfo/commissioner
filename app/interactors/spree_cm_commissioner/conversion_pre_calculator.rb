module SpreeCmCommissioner
  class ConversionPreCalculator < BaseInteractor
    delegate :product_taxon, to: :context

    def call
      update_conversion
      reassign_guests_event_id
    end

    def update_conversion
      product_taxon.update(
        total_count: total_count,
        revenue: revenue
      )
    end

    # reassign event_id if it's wrong.
    def reassign_guests_event_id
      return unless product_taxon.taxon&.event?

      event_id = product_taxon.taxon&.parent_id
      return if event_id.blank?

      SpreeCmCommissioner::Guest
        .where(line_item_id: product_taxon.line_items.pluck(:id))
        .where('event_id IS NULL OR event_id != ?', event_id)
        .find_each do |guest|
        guest.event_id = event_id
        guest.save!
      end
    end

    def total_count
      product_taxon.complete_line_items.pluck(:quantity).compact.sum
    end

    def revenue
      product_taxon.complete_line_items.map(&:amount).compact.sum
    end
  end
end
