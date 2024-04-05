module SpreeCmCommissioner
  module PricingRules
    class ExtraKids < PricingRule
      preference :min_extra_kids, :integer, default: 0
      preference :max_extra_kids, :integer, default: 0

      validate :validate_extra_kids

      def validate_extra_kids
        return errors.add(:min_extra_kids, 'required_min_extra_kids') if preferred_min_extra_kids.blank?
        return errors.add(:max_extra_kids, 'required_max_extra_kids') if preferred_max_extra_kids.blank?

        errors.add(:extra_kids, 'invalid_extra_kids') if preferred_min_extra_kids > preferred_max_extra_kids
      end

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
    end
  end
end