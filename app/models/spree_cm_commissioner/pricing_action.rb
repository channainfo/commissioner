module SpreeCmCommissioner
  class PricingAction < Base
    acts_as_list column: :priority

    belongs_to :pricing_model, optional: false, class_name: 'SpreeCmCommissioner::PricingModel'

    def applicable?(_options)
      raise 'Implement on sub-class of SpreeCmCommissioner::PricingAction'
    end

    def perform(_options = {})
      raise 'Implement on sub-class of SpreeCmCommissioner::PricingAction'
    end

    def description
      self.class.name.demodulize.underscore.humanize
    end
  end
end
