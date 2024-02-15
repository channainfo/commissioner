module SpreeCmCommissioner
  module V2
    module Storefront
      module MenuItemSerializerDecorator
        def self.prepended(base)
          base.attributes :badge
        end
      end
    end
  end
end

if Spree::V2::Storefront::MenuItemSerializer.included_modules.exclude?(SpreeCmCommissioner::V2::Storefront::MenuItemSerializerDecorator)
  Spree::V2::Storefront::MenuItemSerializer.prepend(SpreeCmCommissioner::V2::Storefront::MenuItemSerializerDecorator)
end
