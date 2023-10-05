module SpreeCmCommissioner
  module JsonLd
    class VendorSerializer < ::Spree::V2::Storefront::BaseSerializer
      set_type :vendor

      attributes :name, :slug, :contact_us, :about_us, :min_price, :max_price, :star_rating, :short_description, :full_address, :image_id

      has_one :image, serializer: ::SpreeCmCommissioner::JsonLd::VendorImageSerializer
    end
  end
end
