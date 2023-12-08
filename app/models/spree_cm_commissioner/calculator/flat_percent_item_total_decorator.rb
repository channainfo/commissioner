module SpreeCmCommissioner
  module Calculator
    module FlatPercentItemTotalDecorator
      def compute(object)
        computed_amount = (object.amount * preferred_flat_percent / 100).round(2)
        computed_amount = cap if cap && computed_amount > cap

        [computed_amount, object.amount].min
      end
    end
  end
end

unless Spree::Calculator::FlatPercentItemTotal.included_modules.include?(SpreeCmCommissioner::Calculator::FlatPercentItemTotalDecorator)
  Spree::Calculator::FlatPercentItemTotal.prepend(SpreeCmCommissioner::Calculator::FlatPercentItemTotalDecorator)
end
