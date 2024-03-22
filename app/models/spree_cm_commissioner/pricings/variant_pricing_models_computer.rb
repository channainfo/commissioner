# Calculate the pricing model adjustment for partial or whole quantities of a line item.
#
# For example, if a user purchases 10 items, this class allows inputting a quantity of 3
# and returns the adjustment for that 3-item quantity.
#
# This class also handles group rates. For instance, if a user purchases 25 items, and there
# are set pricing models for 10 and 5 items, it combines 2 for the 10-item pricing model and 1 for the 5-item pricing model.
module SpreeCmCommissioner
  module Pricings
    class VariantPricingModelsComputer
      attr_reader :variant, :quantity, :booking_date, :guest_options, :date_unit_options

      def initialize(variant:, quantity:, booking_date:, guest_options: {}, date_unit_options: {})
        @variant = variant
        @quantity = quantity
        @booking_date = booking_date
        @guest_options = guest_options
        @date_unit_options = date_unit_options
      end

      def call
        applied_pricing_models = []
        remaining_quantity = quantity
        try_group_quantity = quantity

        while try_group_quantity.positive?
          eligible_model = eligible_model_for(quantity: try_group_quantity)

          if eligible_model.blank?
            try_group_quantity -= 1
            next
          end

          # check how many time remain quantity can apply same adjustment.
          group_count = 0
          while remaining_quantity >= try_group_quantity
            group_count += 1
            remaining_quantity -= try_group_quantity
          end

          adjustment_for_group = calculate_adjustment_for(model: eligible_model, quantity: try_group_quantity)

          applied_pricing_models << SpreeCmCommissioner::AppliedPricingModel.new(
            amount: group_count * adjustment_for_group,
            quantity: group_count * try_group_quantity,
            pricing_model: eligible_model,
            preferred_date_unit_options: date_unit_options
          )

          try_group_quantity = remaining_quantity
        end

        applied_pricing_models
      end

      def eligible_model_for(quantity:)
        variant.pricing_models.detect do |model|
          model.eligible?(default_options_for(quantity))
        end
      end

      def calculate_adjustment_for(model:, quantity:)
        rate_options = rate_options_for(quantity: quantity)
        options = default_options_for(quantity).merge(rate: rate_options)

        applicable_actions = model.pricing_actions.select { |action| action.applicable?(options) }
        performed_actions = applicable_actions.map { |action| action.perform(options) }

        performed_actions.sum || 0
      end

      def rate_options_for(quantity:)
        rate_amount = VariantPricingRatesComputer.new(
          variant: variant,
          quantity: quantity,
          booking_date: booking_date,
          date_unit_options: date_unit_options
        ).call.map(&:amount).sum

        { amount: rate_amount, currency: variant.currency }
      end

      def default_options_for(quantity)
        {
          quantity: quantity,
          booking_date: booking_date,
          guest_options: guest_options,
          date_unit_options: date_unit_options
        }
      end
    end
  end
end
