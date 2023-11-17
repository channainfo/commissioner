module SpreeCmCommissioner
  module Promotion
    module Rules
      class Weekend < Date
        DAYS_INTO_WEEK = DateAndTime::Calculations::DAYS_INTO_WEEK

        preference :weekend_days, :array, default: %w[6 0]

        # override
        def date_eligible?(date)
          preferred_weekend_days.include?(date.wday.to_s)
        end
      end
    end
  end
end
