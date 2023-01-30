module Spree
  module PermittedAttributes
    @@vendor_attributes << :logo
    @@line_item_attributes += [:from_date, :to_date]
    @@user_attributes      += [:first_name, :last_name, :dob, :gender, :profile]
  end
end