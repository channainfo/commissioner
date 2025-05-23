module SpreeCmCommissioner
  module JsonLd
    class VendorImageSerializer < ::Spree::V2::Storefront::BaseSerializer
      set_type :vendor_image

      attribute :url do |image|
        url_helpers = Rails.application.routes.url_helpers
        url_helpers.cdn_image_url(image.attachment) if image
      end
    end
  end
end
