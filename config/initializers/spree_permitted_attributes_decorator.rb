module Spree
  module PermittedAttributesDecorator
    def self.prepended(base)
      base.vendor_attributes << :logo
    end
  end
end

Spree::PermittedAttributes.prepend(Spree::PermittedAttributesDecorator)
