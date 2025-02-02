module Spree
  module V2
    module Tenant
      class ProductPlaceSerializer < BaseSerializer
        has_one :place, serializer: Spree::V2::Tenant::PlaceSerializer
      end
    end
  end
end
