module Spree
  module V2
    module Storefront
      module TaxonSerializerDecorator
        def self.prepended(base)
          base.has_one :category_icon, serializer: ::SpreeCmCommissioner::V2::Storefront::AssetSerializer
          base.has_one :app_banner, serializer: ::SpreeCmCommissioner::V2::Storefront::AssetSerializer
          base.has_one :web_banner, serializer: ::SpreeCmCommissioner::V2::Storefront::AssetSerializer
          base.attributes :custom_redirect_url
        end
      end
    end
  end
end

Spree::V2::Storefront::TaxonSerializer.prepend(Spree::V2::Storefront::TaxonSerializerDecorator)
