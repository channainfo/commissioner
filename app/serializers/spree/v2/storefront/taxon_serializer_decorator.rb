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
          base.has_one :video_banner, serializer: ::SpreeCmCommissioner::V2::Storefront::VideoSerializer

          base.attributes :custom_redirect_url, :kind, :subtitle, :from_date, :to_date,
                          :background_color, :foreground_color, :show_badge_status,
                          :purchasable_on, :vendor_id, :available_on, :hide_video_banner

          base.attribute :purchasable_on_app do |taxon|
            taxon.purchasable_on == 'app' || taxon.purchasable_on == 'both'
          end

          base.attribute :purchasable_on_web do |taxon|
            taxon.purchasable_on == 'web' || taxon.purchasable_on == 'both'
          end

          base.cache_options store: nil

          base.attribute :event_url, &:event_url
        end
      end
    end
  end
end

Spree::V2::Storefront::TaxonSerializer.prepend(Spree::V2::Storefront::TaxonSerializerDecorator)
