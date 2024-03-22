module Spree
  module V2
    module Storefront
      module OptionTypeSerializerDecorator
        def self.prepended(base)
          base.attributes :kind, :attr_type, :promoted, :hidden
        end
      end
    end
  end
end

Spree::V2::Storefront::OptionTypeSerializer.prepend Spree::V2::Storefront::OptionTypeSerializerDecorator
