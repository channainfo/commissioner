module SpreeCmCommissioner
  module PricingRules
    class EarlyBird < PricingRule
      preference :booking_date_from, :string
      preference :booking_date_to, :string

      validate :booking_dates

      def applicable?(options = {})
        options[:booking_date].present?
      end

      def eligible?(options = {})
        options[:booking_date].between?(booking_date_from, booking_date_to)
      end

      def booking_date_from
        preferred_booking_date_from.to_date
      end

      def booking_date_to
        preferred_booking_date_to.to_date
      end

      def description
        "Early bird between #{booking_date_from} to #{booking_date_to}"
      end

      private

      def booking_dates
        errors.add(:booking_date_from, 'invalid') if booking_date_from.blank?
        errors.add(:booking_date_to, 'invalid') if booking_date_to.blank?
      end
    end
  end
end
