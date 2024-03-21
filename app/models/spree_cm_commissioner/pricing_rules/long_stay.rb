module SpreeCmCommissioner
  module PricingRules
    class LongStay < PricingRule
      preference :min_stay_duration_in_nights, :integer, default: 0
      preference :max_stay_duration_in_nights, :integer, default: 0

      validate :validate_stay_duration_in_nights

      def validate_stay_duration_in_nights
        return errors.add(:min_stay_duration_in_nights, 'required_min_stay') if preferred_min_stay_duration_in_nights.blank?
        return errors.add(:max_stay_duration_in_nights, 'required_max_stay') if preferred_max_stay_duration_in_nights.blank?

        errors.add(:stay_duration_in_nights, 'invalid') if preferred_min_stay_duration_in_nights > preferred_max_stay_duration_in_nights
      end

      def applicable?(options = {})
        options.dig(:date_unit_options, :date).present? &&
          options.dig(:date_unit_options, :date_index).present? &&
          options.dig(:date_unit_options, :date_range).present?
      end

      # override
      def eligible?(options = {})
        stay_duration_in_nights = options.dig(:date_unit_options, :date_range).size
        stay_duration_in_nights >= preferred_min_stay_duration_in_nights && stay_duration_in_nights <= preferred_min_stay_duration_in_nights
      end

      # override
      def description
        if preferred_min_stay_duration_in_nights == preferred_max_stay_duration_in_nights
          "Long stay booking #{preferred_min_stay_duration_in_nights} nights"
        else
          "Long stay booking #{preferred_min_stay_duration_in_nights}-#{preferred_max_stay_duration_in_nights} nights"
        end
      end
    end
  end
end
