module SpreeCmCommissioner
  module OptionValueDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::OptionValueAttrType
    end

    def display_icon
      return 'cm-default-icon.svg' unless icon&.end_with?(*SpreeCmCommissioner::VectorIcon::ACCEPTED_EXTENSIONS)

      icon
    end
  end
end

unless Spree::OptionValue.included_modules.include?(SpreeCmCommissioner::OptionValueDecorator)
  Spree::OptionValue.prepend SpreeCmCommissioner::OptionValueDecorator
end
