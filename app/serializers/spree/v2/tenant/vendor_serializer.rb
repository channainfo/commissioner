module Spree
  module V2
    module Tenant
      class VendorSerializer < BaseSerializer
        attributes :name, :about_us, :slug, :contact_us,
                   :min_price, :max_price, :star_rating,
                   :short_description, :full_address, :state,
                   :tenant_id

        has_one :image, serializer: :vendor_image
      end
    end
  end
end
