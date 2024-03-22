# Calculate the rate for partial or whole quantities of a line item.
#
# For example, if a user purchases 10 items, this class allows inputting a quantity of 3
# and returns the rate for that 3-item quantity.
#
# This class also handles group rates. For instance, if a user purchases 25 items, and there
# are set rates for 10 and 5 items, it combines 2 for the 10-item rate and 1 for the 5-item rate.
module SpreeCmCommissioner
  module Pricings
    class VariantPricingRatesComputer
      attr_reader :variant, :quantity, :booking_date, :guest_options, :date_unit_options

      def initialize(variant:, quantity:, booking_date:, guest_options: {}, date_unit_options: {})
        @variant = variant
        @quantity = quantity
        @booking_date = booking_date
        @guest_options = guest_options
        @date_unit_options = date_unit_options
      end

      def call
        applied_pricing_rates = []
        remaining_quantity = quantity
        try_group_quantity = quantity

        while try_group_quantity.positive?
          eligible_rate = eligible_rate_for(quantity: try_group_quantity)

          if eligible_rate.blank?
            try_group_quantity -= 1
            next
          end

          # check how many time remain quantity can apply same rate.
          group_count = 0
          while remaining_quantity >= try_group_quantity
            group_count += 1
            remaining_quantity -= try_group_quantity
          end

          rate_amount_for_group = eligible_rate.price_in(variant.currency)

          applied_pricing_rates << SpreeCmCommissioner::AppliedPricingRate.new(
            amount: group_count * rate_amount_for_group.amount,
            quantity: group_count * try_group_quantity,
            pricing_rate: eligible_rate,
            preferred_date_unit_options: date_unit_options
          )

          try_group_quantity = remaining_quantity
        end

        if remaining_quantity.positive?
          applied_pricing_rates << SpreeCmCommissioner::AppliedPricingRate.new(
            amount: variant.price_in(variant.currency).amount * remaining_quantity,
            quantity: remaining_quantity,
            preferred_date_unit_options: date_unit_options
          )
        end

        applied_pricing_rates
      end

      def eligible_rate_for(quantity:)
        variant.pricing_rates.detect do |rate|
          rate.eligible?(default_options_for(quantity))
        end
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
