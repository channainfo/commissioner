module Spree
  module V2
    module Storefront
      module StockLocationSerializerDecorator
        def self.prepended(base)
          base.attributes :lat, :lon, :name, :state_name, :address1, :reference
        end
      end
    end
  end
end

Spree::V2::Storefront::StockLocationSerializer.prepend Spree::V2::Storefront::StockLocationSerializerDecorator
