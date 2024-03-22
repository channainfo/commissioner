module SpreeCmCommissioner
  module PricingRules
    class DatePosition < PricingRule
      preference :min_date_position, :integer, default: 0
      preference :max_date_position, :integer, default: 0

      validate :validate_date_position

      def validate_date_position
        return errors.add(:min_date_position, 'required_min_date_position') if preferred_min_date_position.blank?
        return errors.add(:max_date_position, 'required_max_date_position') if preferred_max_date_position.blank?

        errors.add(:date_position, 'invalid') if preferred_min_date_position > preferred_max_date_position
      end

      def applicable?(options = {})
        options.dig(:date_unit_options, :date_index).present?
      end

      # override
      def eligible?(options = {})
        date_position = options.dig(:date_unit_options, :date_index) + 1
        date_position >= preferred_min_date_position && date_position <= preferred_min_date_position
      end

      # override
      def description
        if preferred_min_date_position == preferred_max_date_position
          "Night #{preferred_min_date_position}"
        else
          "Night #{preferred_min_date_position} - Night #{max_date_position}"
        end
      end
    end
  end
end
