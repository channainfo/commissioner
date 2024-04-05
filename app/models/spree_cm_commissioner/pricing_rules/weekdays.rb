module SpreeCmCommissioner
  module PricingRules
    class Weekdays < PricingRule
      DAYS_INTO_WEEK = DateAndTime::Calculations::DAYS_INTO_WEEK

      preference :weekdays, :array, default: %w[6 0]

      def applicable?(options)
        options.is_a?(Pricings::Options) &&
          options.date_options.is_a?(Pricings::DateOptions) &&
          options.date_options&.date.present?
      end

      # override
      def eligible?(options)
        preferred_weekdays.include?(options.date_options.date.wday.to_s)
      end

      # override
      def description
        preferred_weekdays.map { |day| Date::DAYNAMES[day.to_i] }.to_sentence
      end
    end
  end
end
