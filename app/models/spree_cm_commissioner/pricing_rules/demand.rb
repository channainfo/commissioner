module SpreeCmCommissioner
  module PricingRules
    class Demand < PricingRule
      preference :demand_levels, :integer
    end
  end
end
