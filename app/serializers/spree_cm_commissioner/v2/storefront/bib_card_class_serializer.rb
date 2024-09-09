module SpreeCmCommissioner
  module V2
    module Storefront
      class BibCardClassSerializer < GuestCardClassSerializer
        attribute :background_color, :class_type, :background_color

        has_one :background_image, serializer: SpreeCmCommissioner::V2::Storefront::AssetSerializer
      end
    end
  end
end
