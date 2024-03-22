module SpreeCmCommissioner
  module PricingRules
    class Quantity < PricingRule
      preference :min_quantity, :integer, default: 0
      preference :max_quantity, :integer, default: 0

      validate :validate_quantity

      def validate_quantity
        return errors.add(:min_quantity, 'required_min_quantity') if preferred_min_quantity.blank?
        return errors.add(:max_quantity, 'required_max_quantity') if preferred_max_quantity.blank?

        errors.add(:quantity, 'invalid_quantity') if preferred_min_quantity > preferred_max_quantity
      end

      def applicable?(options = {})
        options[:quantity].present?
      end

      # override
      def eligible?(options = {})
        options[:quantity] >= preferred_min_quantity && options[:quantity] <= preferred_max_quantity
      end

      # override
      def description
        if preferred_min_quantity == preferred_max_quantity
          "Group booking with #{preferred_min_quantity} quantity"
        else
          "Group booking with #{preferred_min_quantity}-#{preferred_max_quantity} quantity"
        end
      end
    end
  end
end
