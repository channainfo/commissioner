module SpreeCmCommissioner
  module PricingActions
    class BuildAdjustmentForAllStayDates < PricingAction
      include ::Spree::CalculatedAdjustments

      def applicable?(_options)
        options[:rate_amount].present? &&
          options[:currency].present? &&
          options[:quantity].present?
      end

      def perform(options)
        compute_amount(options)
      end

      def compute_amount(options)
        object = Struct.new(:amount, :currency, :quantity)
                       .new(options[:rate_amount], options[:currency], options[:quantity])
        compute(object) * -1
      end
    end
  end
end
