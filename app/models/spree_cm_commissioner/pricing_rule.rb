module SpreeCmCommissioner
  class PricingRule < Base
    acts_as_list column: :priority

    belongs_to :ruleable, optional: false, polymorphic: true, inverse_of: :pricing_rules

    def applicable?(_options = {})
      raise 'Implement on sub-class of SpreeCmCommissioner::PricingRule'
    end

    def eligible?(_options = {})
      raise 'Implement on sub-class of SpreeCmCommissioner::PricingRule'
    end

    def description
      raise 'Implement on sub-class of SpreeCmCommissioner::PricingRule'
    end
  end
end
