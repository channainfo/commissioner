module Spree
  module V2
    module Storefront
      module VariantSerializerDecorator
        def self.prepended(base)
          base.attributes :permanent_stock, :need_confirmation, :product_type, :kyc, :reminder_option_value, :started_at_option_value

          base.has_many :stock_locations
          # override
          base.has_many :option_values do |object|
            object.option_values.joins(:option_type).where(spree_option_types: { hidden: false })
          end
        end
      end
    end
  end
end

Spree::V2::Storefront::VariantSerializer.prepend Spree::V2::Storefront::VariantSerializerDecorator
