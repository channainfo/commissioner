module SpreeCmCommissioner
  module Promotion
    module Rules
      class CustomDates < Date
        # [ {"start_date":"2023-12-07", "length":"1", "title":"KNY"} ]
        preference :custom_dates, :array

        before_update :reorder_custom_dates

        def reorder_custom_dates
          self.preferred_custom_dates = preferred_custom_dates.sort_by { |obj| JSON.parse(obj)['start_date'] }
        end

        # override
        def date_eligible?(date)
          return false if preferred_custom_dates.blank?

          preferred_custom_dates.any? do |custom_date|
            match?(custom_date, date)
          end
        end

        private

        def match?(custom_date_json, date)
          custom_date = JSON.parse(custom_date_json)

          start_date = custom_date['start_date']&.to_date
          length = custom_date['length']&.to_i

          return false unless start_date.present? && length.present?

          end_date = start_date + length.days - 1
          date.between?(start_date, end_date)
        end
      end
    end
  end
end
