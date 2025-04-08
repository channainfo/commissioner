module Spree
  module V2
    module Tenant
      class IdCardSerializer < BaseSerializer
        attributes :card_type

        has_one :front_image, serializer: Spree::V2::Tenant::AssetSerializer
        has_one :back_image, serializer: Spree::V2::Tenant::AssetSerializer
      end
    end
  end
end
