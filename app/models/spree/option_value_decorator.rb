module Spree
  module OptionValueDecorator
    def self.prepended(base)
      if base.method_defined?(:whitelisted_ransackable_attributes)
        if base.whitelisted_ransackable_attributes
          base.whitelisted_ransackable_attributes |= %w[presentation]
        else
          base.whitelisted_ransackable_attributes = %w[presentation]
        end
      end
    end

    def display_icon
      self.icon || "backend-tick.svg"
    end
  end
end

Spree::OptionValue.prepend Spree::OptionValueDecorator
