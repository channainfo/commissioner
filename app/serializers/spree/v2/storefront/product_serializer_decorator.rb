module Spree
  module V2
    module Storefront
      module ProductSerializerDecorator
        def self.prepended(base)
          base.has_many :variant_kind_option_types, serializer: :option_type
          base.has_many :product_kind_option_types, serializer: :option_type
          base.has_many :promoted_option_types, serializer: :option_type
          base.has_many :possible_promotions, serializer: ::SpreeCmCommissioner::V2::Storefront::PromotionSerializer

          base.has_one :default_state, serializer: :state
          base.attributes :need_confirmation, :product_type, :kyc
          base.attributes :reveal_description
        end
      end
    end
  end
end

Spree::V2::Storefront::ProductSerializer.prepend Spree::V2::Storefront::ProductSerializerDecorator
