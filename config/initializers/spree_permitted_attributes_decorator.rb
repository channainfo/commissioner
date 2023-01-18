module Spree
  module PermittedAttributesDecorator
    def self.prepended(base)
      base.vendor_attributes << :logo
      base.line_item_attributes << [:from_date, :to_date]
<<<<<<< HEAD
      base.user_attributes << [:first_name, :last_name, :dob, :gender]
=======
      base.user_attributes << [:first_name, :last_name, :dob, :gender, :profile]
>>>>>>> 21e7e3a (close #99-user-profile)
    end
  end
end

Spree::PermittedAttributes.prepend(Spree::PermittedAttributesDecorator)
