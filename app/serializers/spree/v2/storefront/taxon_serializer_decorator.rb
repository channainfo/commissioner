module Spree
  module V2
    module Storefront
      module TaxonSerializerDecorator
        def self.prepended(base)
          base.has_many :vendors, serializer: ::Spree::V2::Storefront::VendorSerializer
          base.has_many :visible_products, serializer: ::Spree::V2::Storefront::ProductSerializer

          base.has_one :category_icon, serializer: ::SpreeCmCommissioner::V2::Storefront::AssetSerializer
          base.has_one :app_banner, serializer: ::SpreeCmCommissioner::V2::Storefront::AssetSerializer
          base.has_one :web_banner, serializer: ::SpreeCmCommissioner::V2::Storefront::AssetSerializer
          base.has_one :home_banner, serializer: ::SpreeCmCommissioner::V2::Storefront::AssetSerializer

          base.attributes :custom_redirect_url, :kind, :subtitle, :from_date, :to_date, :background_color, :foreground_color, :show_badge_status
        end
      end
    end
  end
end

Spree::V2::Storefront::TaxonSerializer.prepend(Spree::V2::Storefront::TaxonSerializerDecorator)
