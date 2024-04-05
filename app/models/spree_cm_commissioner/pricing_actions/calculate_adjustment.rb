module SpreeCmCommissioner
  module PricingActions
    class CalculateAdjustment < PricingAction
      include ::Spree::CalculatedAdjustments

      def applicable?(options)
        options.total_quantity.present? &&
          options.rate_amount.present? &&
          options.rate_currency.present?
      end

      def perform(options)
        compute_amount(options)
      end

      def compute_amount(options)
        object = Struct.new(:amount, :currency, :quantity)
                       .new(options.rate_amount, options.rate_currency, options.total_quantity)
        compute(object)
      end
    end
  end
end
