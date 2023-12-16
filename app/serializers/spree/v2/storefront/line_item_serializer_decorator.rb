module Spree
  module V2
    module Storefront
      module LineItemSerializerDecorator
        def self.prepended(base)
          base.attributes :from_date, :to_date, :need_confirmation, :product_type, :event_status, :amount, :display_amount, :kyc
          base.has_one :vendor

          base.belongs_to :order, serializer: Spree::V2::Storefront::LineItemOrderSerializer
        end
      end
    end
  end
end

Spree::V2::Storefront::LineItemSerializer.prepend Spree::V2::Storefront::LineItemSerializerDecorator
