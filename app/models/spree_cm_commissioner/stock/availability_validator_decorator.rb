module SpreeCmCommissioner
  module Stock
    module AvailabilityValidatorDecorator
      # override
      def item_available?(line_item, quantity)
        SpreeCmCommissioner::Stock::LineItemAvailabilityChecker.new(line_item)
                                                               .can_supply?(quantity)
      end
    end
  end
end

unless Spree::Stock::AvailabilityValidator.included_modules.include?(SpreeCmCommissioner::Stock::AvailabilityValidatorDecorator)
  Spree::Stock::AvailabilityValidator.prepend(SpreeCmCommissioner::Stock::AvailabilityValidatorDecorator)
end
