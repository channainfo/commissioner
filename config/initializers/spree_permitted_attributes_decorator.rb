module Spree
  module PermittedAttributesDecorator
    def self.prepended(base)
      base.vendor_attributes << :logo
      base.line_item_attributes << [:from_date, :to_date]
      base.user_attributes << [:first_name, :last_name, :dob, :gender]
    end
  end
end

Spree::PermittedAttributes.prepend(Spree::PermittedAttributesDecorator)
