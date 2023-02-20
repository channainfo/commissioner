module SpreeCmCommissioner
  module V2
    module Storefront
      class AssetSerializer < BaseSerializer
        include ::Spree::Api::V2::ImageTransformationConcern

        attributes :styles, :position, :alt, :original_url
      end
    end
  end
end
