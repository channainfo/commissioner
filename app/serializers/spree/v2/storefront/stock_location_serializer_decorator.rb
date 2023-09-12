module Spree
  module V2
    module Storefront
      module StockLocationSerializerDecorator
        def self.prepended(base)
          base.attributes :lat, :lon, :name, :address1, :reference

          base.has_one :state
        end
      end
    end
  end
end

Spree::V2::Storefront::StockLocationSerializer.prepend Spree::V2::Storefront::StockLocationSerializerDecorator
