module Spree
  module OptionValueDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::AttrTypeValidation

      base.act_as_presentation

      if base.method_defined?(:whitelisted_ransackable_attributes)
        if base.whitelisted_ransackable_attributes
          base.whitelisted_ransackable_attributes |= %w[presentation]
        else
          base.whitelisted_ransackable_attributes = %w[presentation]
        end
      end
    end

    def display_icon
      return "cm-default-icon.svg" unless icon&.end_with?(".svg")
      icon
    end
  end
end

Spree::OptionValue.prepend Spree::OptionValueDecorator
