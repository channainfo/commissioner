module Spree
  module PermittedAttributes
    @@vendor_attributes << :logo
    @@line_item_attributes += %i[from_date to_date]
    @@user_attributes      += %i[first_name last_name dob gender profile]
    @@taxon_attributes     += %i[category_icon]
  end
end
