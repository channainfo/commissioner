module SpreeCmCommissioner
  module PricingRules
    class GuestOccupations < PricingRule
      preference :occupations, :array
    end
  end
end
