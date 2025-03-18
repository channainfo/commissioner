module Spree
  module V2
    module Tenant
      class ImageSerializer < BaseSerializer
        set_type :image

        attributes :styles, :position, :alt, :created_at, :updated_at, :original_url
      end
    end
  end
end
