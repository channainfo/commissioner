module Spree
  module V2
    module Storefront
      module VendorSerializerDecorator
        def self.prepended(base)
          base.attributes :min_price, :max_price, :star_rating

          base.has_many :stock_locations
          base.has_many :variants, serializer: 'Spree::Variant'
          base.has_many :photos, serializer: :vendor_photo
          base.has_many :vendor_kind_option_types, serializer: :option_type
          base.has_one :logo, serializer: :vendor_logo
        end
      end
    end
  end
end

Spree::V2::Storefront::VendorSerializer.prepend Spree::V2::Storefront::VendorSerializerDecorator
