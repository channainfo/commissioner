module Spree
  module V2
    module Storefront
      module OrderSerializerDecorator
        def self.prepended(base)
          base.attribute :token
          base.attribute :user_type do |order|
            order.user_id.nil? ? 'guest' : 'number'
          end
        end
      end
    end
  end
end

Spree::V2::Storefront::OrderSerializer.prepend Spree::V2::Storefront::OrderSerializerDecorator
