module Spree
  module V2
    module Organizer
      class IdCardSerializer < BaseSerializer
        attributes :card_type

        has_one :front_image, serializer: ::Spree::V2::Organizer::ImageSerializer
        has_one :back_image, serializer: ::Spree::V2::Organizer::ImageSerializer
      end
    end
  end
end
