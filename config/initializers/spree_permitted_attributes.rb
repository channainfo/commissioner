module Spree
  module PermittedAttributes
    @@vendor_attributes << :logo
    @@line_item_attributes += %i[from_date to_date line_item_seats_attributes date]
    @@user_attributes      += %i[first_name last_name dob gender profile]
    @@taxon_attributes     += %i[category_icon]
    @@checkout_attributes  += %i[phone_number country_code]
  end
end
