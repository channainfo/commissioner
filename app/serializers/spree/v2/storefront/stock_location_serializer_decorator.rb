module Spree
  module V2
    module Storefront
      module StockLocationSerializerDecorator
        def self.prepended(base)
          base.attributes :lat, :lon, :name, :address1, :reference, :phone

          base.has_one :state
          base.has_many :nearby_places, serializer: :nearby_place
          base.has_one :logo, serializer: ::SpreeCmCommissioner::V2::Storefront::AssetSerializer
        end
      end
    end
  end
end

Spree::V2::Storefront::StockLocationSerializer.prepend Spree::V2::Storefront::StockLocationSerializerDecorator
