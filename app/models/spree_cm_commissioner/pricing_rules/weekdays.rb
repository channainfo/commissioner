module SpreeCmCommissioner
  module PricingRules
    class Weekdays < PricingRule
      DAYS_INTO_WEEK = DateAndTime::Calculations::DAYS_INTO_WEEK

      preference :weekdays, :array, default: %w[6 0]

      def applicable?(options = {})
        return false if options.dig(:date_unit_options, :date).blank?

        options.dig(:date_unit_options, :date).is_a?(Date) || options.dig(:date_unit_options, :date).is_a?(DateTime)
      end

      # override
      def eligible?(options = {})
        date = options.dig(:date_unit_options, :date)

        preferred_weekdays.include?(date.wday.to_s)
      end

      # override
      def description
        preferred_weekdays.map { |day| Date::DAYNAMES[day.to_i] }.to_sentence
      end
    end
  end
end
