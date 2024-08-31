module Spree
  module V2
    module Storefront
      module VariantSerializerDecorator
        def self.prepended(base)
          base.attributes :need_confirmation, :product_type, :kyc, :allow_anonymous_booking,
                          :reminder_in_hours, :start_time, :delivery_option,
                          :number_of_guests, :max_quantity_per_order, :discontinue_on, :high_demand

          base.attribute :delivery_required, &:delivery_required?

          base.has_many :stock_locations
          base.has_many :stock_items, serializer: ::SpreeCmCommissioner::V2::Storefront::StockItemSerializer
        end
      end
    end
  end
end

Spree::V2::Storefront::VariantSerializer.prepend Spree::V2::Storefront::VariantSerializerDecorator
