module SpreeCmCommissioner
  module Pricings
    class VariantPricingModelsComputer
      attr_reader :variant, :base_options

      def initialize(variant:, base_options:)
        @variant = variant
        @base_options = base_options
      end

      def call
        (1..base_options.total_quantity).filter_map do |quantity_position|
          apply_model_for(quantity_position: quantity_position)
        end
      end

      def apply_model_for(quantity_position:)
        options = base_options.copy_with(quantity_position: quantity_position)
        eligible_model = variant.pricing_models.detect { |model| model.eligible?(options) }

        return nil if eligible_model.blank?

        applied_rate = rate_amount_for(quantity_position: quantity_position)
        options_with_rate_amount = options.copy_with(rate_amount: applied_rate.amount, rate_currency: variant.currency)

        applicable_actions = eligible_model.pricing_actions.select { |action| action.applicable?(options_with_rate_amount) }
        performed_actions = applicable_actions.map { |action| action.perform(options_with_rate_amount) }

        return nil if performed_actions.empty? || performed_actions.sum.zero?

        SpreeCmCommissioner::AppliedPricingModel.new(
          amount: performed_actions.sum || 0,
          pricing_model: eligible_model,
          pricing_rate: applied_rate.pricing_rate,
          options: options_with_rate_amount.to_h
        )
      end

      def rate_amount_for(quantity_position:)
        VariantPricingRatesComputer.new(variant: variant, base_options: base_options).apply_rate_for(quantity_position: quantity_position)
      end
    end
  end
end
