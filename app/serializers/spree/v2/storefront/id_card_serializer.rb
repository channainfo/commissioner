module Spree
  module V2
    module Storefront
      class IdCardSerializer < BaseSerializer
        attributes :card_type

        has_one :front_image, serializer: SpreeCmCommissioner::V2::Storefront::AssetSerializer
        has_one :back_image, serializer: SpreeCmCommissioner::V2::Storefront::AssetSerializer
      end
    end
  end
end
