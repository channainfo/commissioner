module Spree
  module PermittedAttributesDecorator
    def self.prepended(base)
      base.vendor_attributes << :logo
      base.line_item_attributes << [:from_date, :to_date]
    end
  end
end

Spree::PermittedAttributes.prepend(Spree::PermittedAttributesDecorator)
