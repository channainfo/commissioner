module Spree
  module V2
    module Storefront
      module OptionTypeSerializerDecorator
        def self.prepended(base)
          base.attributes :is_master, :attr_type
        end
      end
    end
  end
end

Spree::V2::Storefront::OptionTypeSerializer.prepend Spree::V2::Storefront::OptionTypeSerializerDecorator