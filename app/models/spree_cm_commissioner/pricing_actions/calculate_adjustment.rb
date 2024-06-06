module SpreeCmCommissioner
  module PricingActions
    class CalculateAdjustment < PricingAction
      include ::Spree::CalculatedAdjustments

      before_create -> { self.calculator ||= Spree::Calculator::FlatRate.new }

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

      def description
        case calculator.class.name
        when 'Spree::Calculator::PercentOnLineItem'
          description = "#{calculator.preferred_percent}%"
          description = "+#{description}" if calculator.preferred_percent >= 0
          description
        when 'Spree::Calculator::FlatRate'
          description = Spree::Money.new(calculator.preferred_amount, currency: calculator.preferred_currency).to_s
          description = "+#{description}" if calculator.preferred_amount >= 0
          description
        end
      end

      def available_calculators
        [
          Spree::Calculator::PercentOnLineItem,
          Spree::Calculator::FlatRate
        ]
      end
    end
  end
end
