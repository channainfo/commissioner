module SpreeCmCommissioner
  module V2
    module Storefront
      class BookingCardClassSerializer < GuestCardClassSerializer
        attributes :name, :class_type
        has_one :background_image, serializer: SpreeCmCommissioner::V2::Storefront::AssetSerializer
      end
    end
  end
end
