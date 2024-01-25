module Spree
  module V2
    module Storefront
      module LineItemSerializerDecorator
        def self.prepended(base)
          base.attributes :from_date, :to_date, :need_confirmation, :product_type, :event_status, :amount, :display_amount,
                          :kyc, :remaining_total_guests

          base.has_one :vendor

          base.belongs_to :order, serializer: Spree::V2::Storefront::LineItemOrderSerializer

          base.has_many :guests, serializer: SpreeCmCommissioner::V2::Storefront::GuestSerializer

          base.attribute :allowed_to_decrease_quantity, &:allowed_to_decrease_quantity?
        end
      end
    end
  end
end

Spree::V2::Storefront::LineItemSerializer.prepend Spree::V2::Storefront::LineItemSerializerDecorator
