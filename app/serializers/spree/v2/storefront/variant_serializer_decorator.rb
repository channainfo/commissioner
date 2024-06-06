module Spree
  module V2
    module Storefront
      module VariantSerializerDecorator
        def self.prepended(base)
          base.attributes :permanent_stock, :need_confirmation, :product_type, :kyc,
                          :reminder_in_time, :start_time, :delivery_option,
                          :number_of_guests, :max_quantity_per_order

          base.attribute :delivery_required, &:delivery_required?

          base.has_many :stock_locations
        end
      end
    end
  end
end

Spree::V2::Storefront::VariantSerializer.prepend Spree::V2::Storefront::VariantSerializerDecorator
