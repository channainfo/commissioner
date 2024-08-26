module Spree
  module V2
    module Storefront
      module AddressSerializerDecorator
        def self.prepended(base)
          base.attributes :age, :gender
        end
      end
    end
  end
end

Spree::V2::Storefront::AddressSerializer.prepend Spree::V2::Storefront::AddressSerializerDecorator
