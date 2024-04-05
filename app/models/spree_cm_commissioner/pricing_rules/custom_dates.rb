module SpreeCmCommissioner
  module PricingRules
    class CustomDates < PricingRule
      # [ {"start_date":"2023-12-07", "length":"1", "title":"KNY"} ]
      preference :custom_dates, :array

      before_update :sort_custom_dates, unless: -> { preferred_custom_dates.blank? }

      def sort_custom_dates
        self.preferred_custom_dates = preferred_custom_dates.sort_by { |obj| JSON.parse(obj)['start_date'] }
      end

      def applicable?(options)
        options.is_a?(Pricings::Options) &&
          options.date_options.is_a?(Pricings::DateOptions) &&
          options.date_options&.date.present?
      end

      # override
      def eligible?(options)
        return false if preferred_custom_dates.blank?

        preferred_custom_dates.any? do |custom_date|
          match?(custom_date, options.date_options.date)
        end
      end

      def match?(custom_date_json, date)
        custom_date = JSON.parse(custom_date_json)

        start_date = custom_date['start_date']&.to_date
        length = custom_date['length']&.to_i

        return false unless start_date.present? && length.present?

        end_date = start_date + length.days - 1
        date.between?(start_date, end_date)
      end

      # override
      def description
        preferred_custom_dates.pluck(:title).to_sentence
      end
    end
  end
end
