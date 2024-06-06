module SpreeCmCommissioner
  module LineItemDurationable
    extend ActiveSupport::Concern

    included do
      before_validation :set_duration, if: -> { event.present? }
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

    def event
      taxons.event.first
    end

    def set_duration
      self.from_date ||= event.from_date
      self.to_date ||= event.to_date
    end
  end
end
