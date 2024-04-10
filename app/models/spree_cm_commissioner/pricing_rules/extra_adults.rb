module SpreeCmCommissioner
  module PricingRules
    class ExtraAdults < PricingRule
      preference :min_extra_adults, :integer, default: 1
      preference :max_extra_adults, :integer, default: 1

      validate :validate_extra_adults

      # override
      def applicable?(options)
        options.is_a?(Pricings::Options) &&
          options.guest_options.is_a?(Pricings::GuestOptions) &&
          options.guest_options&.extra_adults.present?
      end

      # override
      def eligible?(options)
        extra_adults = options.guest_options.extra_adults
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

      private

      def validate_extra_adults
        errors.add(:min_extra_adults, 'invalid_min_extra_adults') if preferred_min_extra_adults <= 0
        errors.add(:max_extra_adults, 'invalid_max_extra_adults') if preferred_max_extra_adults <= 0
        errors.add(:extra_adults, 'invalid_extra_adults') if preferred_min_extra_adults > preferred_max_extra_adults
      end
    end
  end
end
