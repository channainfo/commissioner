module SpreeCmCommissioner
  module LineItemDurationable
    extend ActiveSupport::Concern

    included do
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

      date_range.size
    end

    def date_range
      return [] unless date_present?

      (from_date.to_date..to_date.to_date).to_a
    end

    def checkin_date
      from_date&.to_date
    end

    def checkout_date
      return to_date ? to_date.to_date - 1.day : nil if accommodation?

      to_date&.to_date
    end

    def event
      taxons.event.first
    end

    private

    def set_duration
      self.from_date ||= variant.start_date_time
      self.to_date ||= variant.end_date_time
    end
  end
end
