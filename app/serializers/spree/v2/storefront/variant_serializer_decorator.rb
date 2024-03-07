module Spree
  module V2
    module Storefront
      module VariantSerializerDecorator
        def self.prepended(base)
          base.attributes :permanent_stock, :need_confirmation, :product_type, :kyc, :reminder_option_value, :started_at_option_value

          base.has_many :stock_locations
          base.has_many :visible_option_values, serializer: Spree::V2::Storefront::OptionValueSerializer
        end
      end
    end
  end
end

Spree::V2::Storefront::VariantSerializer.prepend Spree::V2::Storefront::VariantSerializerDecorator
