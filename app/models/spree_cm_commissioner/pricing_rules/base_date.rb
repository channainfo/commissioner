module SpreeCmCommissioner
  module PricingRules
    class BaseDate < PricingRule
      # override
      def applicable?(options)
        options.is_a?(Pricings::Options) &&
          options.date_options.is_a?(Pricings::DateOptions) &&
          options.date_options&.date.present?
      end
    end
  end
end
