module SpreeCmCommissioner
  module PricingRules
    class GroupBooking < PricingRule
      preference :quantity, :integer, default: 1

      validates :preferred_quantity, numericality: { only_integer: true, greater_than: 0 }

      # override
      def applicable?(options)
        options.is_a?(Pricings::Options) &&
          options.total_quantity.present? &&
          options.quantity_position.present?
      end

      # override
      def eligible?(options)
        eligible_max_position = calculate_max_eligible_position(options.total_quantity)
        options.quantity_position.between?(1, eligible_max_position)
      end

      def calculate_max_eligible_position(total_quantity)
        group_count = (total_quantity / preferred_quantity).floor
        group_count * preferred_quantity
      end

      # override
      def description
        "Group booking with #{preferred_quantity} quantity"
      end
    end
  end
end
