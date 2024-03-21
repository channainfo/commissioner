module SpreeCmCommissioner
  module PricingActions
    class CalculateAdjustment < PricingAction
      include ::Spree::CalculatedAdjustments

      def applicable?(options)
        options[:quantity].present? &&
          options.dig(:rate, :amount).present? &&
          options.dig(:rate, :currency).present?
      end

      def perform(options)
        compute_amount(options)
      end

      def compute_amount(options)
        rate_options = options[:rate]

        object = Struct.new(:amount, :currency, :quantity)
                       .new(rate_options[:amount], rate_options[:currency], options[:quantity])

        compute(object)
      end
    end
  end
end
