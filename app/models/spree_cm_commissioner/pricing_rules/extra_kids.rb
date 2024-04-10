module SpreeCmCommissioner
  module PricingRules
    class ExtraKids < PricingRule
      preference :min_extra_kids, :integer, default: 1
      preference :max_extra_kids, :integer, default: 1

      validates :preferred_min_extra_kids, numericality: { only_integer: true, greater_than: 0 }
      validates :preferred_max_extra_kids, numericality: { only_integer: true, greater_than: 0 }

      validate :validate_extra_kids

      # override
      def applicable?(options)
        options.is_a?(Pricings::Options) &&
          options.guest_options.is_a?(Pricings::GuestOptions) &&
          options.guest_options&.extra_kids.present?
      end

      # override
      def eligible?(options)
        extra_kids = options.guest_options&.extra_kids
        extra_kids.positive? && extra_kids >= preferred_min_extra_kids && extra_kids <= preferred_max_extra_kids
      end

      # override
      def description
        if preferred_min_extra_kids == preferred_max_extra_kids
          "Booking with extra #{preferred_min_extra_kids} kids"
        else
          "Booking with extra #{preferred_min_extra_kids}-#{preferred_max_extra_kids} kids"
        end
      end

      private

      def validate_extra_kids
        errors.add(:extra_kids, 'invalid_extra_kids') if preferred_min_extra_kids > preferred_max_extra_kids
      end
    end
  end
end
