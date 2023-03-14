module SpreeCmCommissioner
  class PricingModel
    module Actions
      class CreateListingPriceAdjustment < SpreeCmCommissioner::PricingModelAction
        include Spree::AdjustmentSource
        include Spree::CalculatedAdjustments

        has_many :adjustments, as: :source, class_name: 'Spree::Adjustment'

        before_validation -> { self.calculator ||= Calculator::FlatPercentItemTotal.new }

        def perform(options = {})
          adjustable = options[:adjustable]
          create_unique_adjustment(nil, adjustable)
        end

        def compute_amount(adjustable)
          compute(adjustable) * -1
        end
      end
    end
  end
end
