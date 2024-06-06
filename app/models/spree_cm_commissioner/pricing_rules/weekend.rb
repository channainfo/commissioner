module SpreeCmCommissioner
  module PricingRules
    class Weekend < BaseDate
      DAYS_INTO_WEEK = DateAndTime::Calculations::DAYS_INTO_WEEK

      preference :weekend_days, :array, default: %w[6 0]

      # override
      def eligible?(options)
        date_eligible?(options.date_options.date)
      end

      def date_eligible?(date)
        preferred_weekend_days.include?(date.wday.to_s)
      end

      # override
      def description
        preferred_weekend_days.map { |day| Date::DAYNAMES[day.to_i] }.to_sentence
      end
    end
  end
end
