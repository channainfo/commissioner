module SpreeCmCommissioner
  module Promotion
    module Rules
      class Weekend < Date
        DAYS_INTO_WEEK = DateAndTime::Calculations::DAYS_INTO_WEEK

        # [ {"start_date":"2023-12-07", "length":"1", "title":"KNY"} ]
        preference :exception_dates, :array
        preference :weekend_days, :array, default: %w[6 0]

        before_update :reorder_exception_dates

        def reorder_exception_dates
          self.preferred_exception_dates = preferred_exception_dates.sort_by { |obj| JSON.parse(obj)['start_date'] }
        end

        # override
        def date_eligible?(date)
          return false if exception?(date)

          weekend?(date)
        end

        def weekend?(date)
          preferred_weekend_days.include?(date.wday.to_s)
        end

        def exception?(date)
          return false if preferred_exception_dates.blank?

          preferred_exception_dates.any? do |exception|
            match?(exception, date)
          end
        end

        private

        def match?(exception_date_json, date)
          exception_date = JSON.parse(exception_date_json)

          start_date = exception_date['start_date']&.to_date
          length = exception_date['length']&.to_i

          return false unless start_date.present? && length.present?

          end_date = start_date + length.days - 1
          date.between?(start_date, end_date)
        end
      end
    end
  end
end
