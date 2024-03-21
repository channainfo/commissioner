module SpreeCmCommissioner
  module PricingRules
    class PaymentMethods < PricingRule
      preference :payment_method_ids, :array, default: []
    end
  end
end
