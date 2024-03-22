module SpreeCmCommissioner
  class PricingAction < Base
    acts_as_list column: :priority

    belongs_to :pricing_model, class_name: 'SpreeCmCommissioner::PricingModel'

    def applicable?(_options)
      raise 'Implement on sub-class of SpreeCmCommissioner::PricingAction'
    end

    def perform(_options = {})
      raise 'Implement on sub-class of SpreeCmCommissioner::PricingAction'
    end

    def description
      "#{self.class.name.demodulize.underscore.humanize.sub!('Build adjustment', '')} #{adjustment_desc}"
    end

    # eg. +10%, +5$
    def adjustment_desc
      if calculator.try(:preferred_amount)
        adjustment_desc = Spree::Money.new(calculator.preferred_amount, currency: calculator.preferred_currency).to_s
        adjustment_desc = "+#{adjustment_desc}" if calculator.preferred_amount.positive?
        adjustment_desc
      elsif calculator.try(:preferred_percent)
        adjustment_desc = "#{calculator.preferred_percent}%"
        adjustment_desc = "+#{adjustment_desc}" if calculator.preferred_percent.positive?
        adjustment_desc
      else
        calculator.preferences
      end
    end
  end
end
