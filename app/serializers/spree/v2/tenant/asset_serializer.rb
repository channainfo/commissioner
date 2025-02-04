module Spree
  module V2
    module Tenant
      class AssetSerializer < BaseSerializer
        include ::Spree::Api::V2::ImageTransformationConcern

        attributes :alt, :original_url, :position, :styles
      end
    end
  end
end
