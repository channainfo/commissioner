module Spree
  module V2
    module Storefront
      module WishedItemSerializerDecorator
        def self.prepended(base)
          base.belongs_to :wishlist, serializer: Spree::V2::Storefront::WishlistSerializer
        end
      end
    end
  end
end

Spree::V2::Storefront::WishedItemSerializer.prepend Spree::V2::Storefront::WishedItemSerializerDecorator
