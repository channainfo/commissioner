module Spree
  module V2
    module Tenant
      class OrderSerializer < Spree::V2::Storefront::CartSerializer
        has_many :guest_card_classes, serializer: Spree::V2::Tenant::BookingCardClassSerializer
      end
    end
  end
end
