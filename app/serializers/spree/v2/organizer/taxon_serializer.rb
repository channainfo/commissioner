module Spree
  module V2
    module Organizer
      class TaxonSerializer < BaseSerializer
        attributes :name
        has_one :app_banner, serializer: Spree::V2::Organizer::AssetSerializer
      end
    end
  end
end
