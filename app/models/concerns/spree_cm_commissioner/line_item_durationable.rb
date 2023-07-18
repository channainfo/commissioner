module SpreeCmCommissioner
  module LineItemDurationable
    extend ActiveSupport::Concern

    def date_present?
      from_date.present? && to_date.present?
    end

    def amount_per_date_unit
      amount / date_unit
    end

    def date_unit
      return nil unless reservation?

      return number_of_nights if accommodation?
    end

    # Example:
    # 24-10-2023 -> 25-10-2023 = 1 night
    def number_of_nights
      return nil unless date_present?

      (to_date.to_date - from_date.to_date)
    end

    # Example:
    # 24-10-2023 -> 25-10-2023 = 2 days
    def number_of_days
      return nil unless date_present?

      (to_date.to_date - from_date.to_date) + 1
    end

    def date_range
      return [] unless date_present?

      from_date.to_date..to_date.to_date
    end
  end
end
