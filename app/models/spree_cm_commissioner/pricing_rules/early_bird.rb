module SpreeCmCommissioner
  module PricingRules
    class EarlyBird < PricingRule
      preference :booking_date_from, :string
      preference :booking_date_to, :string

      validate :validate_booking_dates

      def booking_date_from = preferred_booking_date_from.to_date
      def booking_date_to = preferred_booking_date_to.to_date

      # override
      def applicable?(options)
        options.is_a?(Pricings::Options) &&
          options.booking_date.present?
      end

      # override
      def eligible?(options)
        options.booking_date.between?(booking_date_from, booking_date_to)
      end

      # override
      def description
        "Early bird between #{booking_date_from} to #{booking_date_to}"
      end

      private

      def validate_booking_dates
        return errors.add(:booking_date_from, 'invalid_booking_date_from') if booking_date_from.blank?
        return errors.add(:booking_date_to, 'invalid_booking_date_to') if booking_date_to.blank?

        errors.add(:booking_date, 'invalid_booking_date') if booking_date_to < booking_date_from
      end
    end
  end
end
