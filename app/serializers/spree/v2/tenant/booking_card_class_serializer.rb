module Spree
  module V2
    module Tenant
      class BookingCardClassSerializer < GuestCardClassSerializer
        attributes :name, :class_type
        has_one :background_image, serializer: SpreeCmCommissioner::V2::Storefront::AssetSerializer
      end
    end
  end
end
