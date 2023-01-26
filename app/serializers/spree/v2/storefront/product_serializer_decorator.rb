module Spree
  module V2
    module Storefront
      module ProductSerializerDecorator
        def self.prepended(base)
          base.has_many :variant_kind_option_types, serializer: :option_type
          base.has_many :product_kind_option_types, serializer: :option_type
          base.has_many :promoted_option_types, serializer: :option_type
        end
      end
    end
  end
end

Spree::V2::Storefront::ProductSerializer.prepend Spree::V2::Storefront::ProductSerializerDecorator