module SpreeCmCommissioner
  class Tenant < SpreeCmCommissioner::Base
    has_many :vendors, class_name: 'Spree::Vendor'
  end
end
