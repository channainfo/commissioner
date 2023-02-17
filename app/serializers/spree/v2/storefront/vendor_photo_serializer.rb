module Spree
  module V2
    module Storefront
      class VendorPhotoSerializer < BaseSerializer
        include ::Spree::Api::V2::ImageTransformationConcern

        set_type :photo

        attributes :styles, :position, :alt, :original_url
      end
    end
  end
end
