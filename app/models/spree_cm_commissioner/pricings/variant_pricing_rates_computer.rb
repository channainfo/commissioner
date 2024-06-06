# Calculate rate price for each quantity unit of variant.
module SpreeCmCommissioner
  module Pricings
    class VariantPricingRatesComputer
      attr_reader :variant, :base_options

      def initialize(variant:, base_options:)
        @variant = variant
        @base_options = base_options
      end

      def call
        (1..base_options.total_quantity).map do |quantity_position|
          apply_rate_for(quantity_position: quantity_position)
        end
      end

      def apply_rate_for(quantity_position:)
        options = base_options.copy_with(quantity_position: quantity_position)
        eligible_rate = variant.pricing_rates.detect { |rate| rate.eligible?(options) }
        rate_price = eligible_rate&.price_in(variant.currency) || normal_rate_price

        SpreeCmCommissioner::AppliedPricingRate.new(
          amount: rate_price.amount,
          pricing_rate: eligible_rate,
          options: options.to_h
        )
      end

      def normal_rate_price
        variant.price_in(variant.currency)
      end
    end
  end
end
