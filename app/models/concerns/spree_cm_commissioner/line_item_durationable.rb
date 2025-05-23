module SpreeCmCommissioner
  module LineItemDurationable
    extend ActiveSupport::Concern

    included do
      before_validation :set_event_id
      before_validation :set_duration
    end

    def date_present?
      from_date.present? && to_date.present?
    end

    def amount_per_date_unit
      amount / date_unit
    end

    def date_unit
      return nil unless permanent_stock?

      date_range_excluding_checkout.size if accommodation?
    end

    def date_range_excluding_checkout
      return [] unless date_present?

      date_range = (from_date.to_date..to_date.to_date).to_a
      date_range.pop if date_range.size > 1
      date_range
    end

    def date_range_including_checkout
      return [] unless date_present?

      (from_date.to_date..to_date.to_date).to_a
    end

    def date_range
      if accommodation?
        date_range_excluding_checkout
      else
        date_range_including_checkout
      end
    end

    private

    def set_event_id
      self.event_id ||= product.event_id
    end

    # Line item date now depends directly on the event date and variant date.
    # No longer depend on the event section date.
    # This keeps the setup simple for the organizer and consistent for users.
    def set_duration
      self.from_date ||= variant.start_date_time || event&.from_date
      self.to_date ||= variant.end_date_time || event&.to_date
    end
  end
end
