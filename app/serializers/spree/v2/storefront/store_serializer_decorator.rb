module Spree
  module V2
    module Storefront
      module StoreSerializerDecorator
        def self.prepended(base)
          base.attributes :term_and_condition_promotion
        end
      end
    end
  end
end

Spree::V2::Storefront::StoreSerializer.prepend Spree::V2::Storefront::StoreSerializerDecorator
