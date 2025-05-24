module SpreeCmCommissioner
  module Calculator
    module PercentOnLineItemDecorator
      def compute(object)
        computed_amount = (object.amount * preferred_percent / 100).round(2)
        computed_amount = cap if cap && computed_amount > cap

        [computed_amount, object.amount].min
      end
    end
  end
end

unless Spree::Calculator::PercentOnLineItem.included_modules.include?(SpreeCmCommissioner::Calculator::PercentOnLineItemDecorator)
  Spree::Calculator::PercentOnLineItem.prepend(SpreeCmCommissioner::Calculator::PercentOnLineItemDecorator)
end
