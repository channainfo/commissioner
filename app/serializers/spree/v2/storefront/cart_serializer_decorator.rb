module Spree
  module V2
    module Storefront
      module CartSerializerDecorator
        def self.prepended(base)
          base.attributes :phone_number, :intel_phone_number, :country_code
        end
      end
    end
  end
end

Spree::V2::Storefront::CartSerializer.prepend Spree::V2::Storefront::CartSerializerDecorator
