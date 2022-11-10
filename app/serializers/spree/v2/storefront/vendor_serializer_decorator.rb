module Spree
  module V2
    module Storefront
      module VendorSerializerDecorator
        def self.prepended(base)
          base.has_many :stock_locations
          base.has_one :logo, serializer: :vendor_logo
        end
      end
    end
  end
end

Spree::V2::Storefront::VendorSerializer.prepend Spree::V2::Storefront::VendorSerializerDecorator
