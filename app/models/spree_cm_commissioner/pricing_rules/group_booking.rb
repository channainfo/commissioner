module SpreeCmCommissioner
  module PricingRules
    class GroupBooking < PricingRule
      preference :quantity, :integer, default: 0

      # override
      def applicable?(options)
        options.is_a?(Pricings::Options) &&
          options.quantity_position.present?
      end

      # override
      def eligible?(options)
        group_count = (options.total_quantity / preferred_quantity).floor
        eligible_max_position = group_count * preferred_quantity

        options.quantity_position.between?(1, eligible_max_position)
      end

      # override
      def description
        "Group booking with #{preferred_quantity} quantity"
      end
    end
  end
end
