module SpreeCmCommissioner
  module PricingRules
    class ExtraAdults < PricingRule
      preference :min_extra_adults, :integer, default: 0
      preference :max_extra_adults, :integer, default: 0

      validate :validate_extra_adults

      def validate_extra_adults
        return errors.add(:min_extra_adults, 'required_min_extra_adults') if preferred_min_extra_adults.blank?
        return errors.add(:max_extra_adults, 'required_max_extra_adults') if preferred_max_extra_adults.blank?

        errors.add(:extra_adults, 'invalid_extra_adults') if preferred_min_extra_adults > preferred_max_extra_adults
      end

      def applicable?(options = {})
        options.dig(:guest_options, :extra_adults).present?
      end

      # override
      def eligible?(options = {})
        extra_adults = options.dig(:guest_options, :extra_adults)
        extra_adults.positive? && extra_adults >= preferred_min_extra_adults && extra_adults <= preferred_max_extra_adults
      end

      # override
      def description
        if preferred_min_extra_adults == preferred_max_extra_adults
          "Booking with extra #{preferred_min_extra_adults} adults"
        else
          "Booking with extra #{preferred_min_extra_adults}-#{preferred_max_extra_adults} adults"
        end
      end
    end
  end
end
