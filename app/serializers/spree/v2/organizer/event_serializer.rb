module Spree
  module V2
    module Organizer
      class EventSerializer < BaseSerializer
        attributes :name, :subtitle, :from_date, :to_date, :description, :vendor_id, :permalink

        has_many :vendors, serializer: ::Spree::V2::Storefront::VendorSerializer
        belongs_to :parent, serializer: ::Spree::V2::Storefront::TaxonSerializer
        belongs_to :taxonomy, serializer: ::Spree::V2::Storefront::TaxonomySerializer
        has_many :children, serializer: ::Spree::V2::Storefront::TaxonSerializer
        has_many :products, serializer: ::Spree::V2::Storefront::ProductSerializer

        has_one :category_icon, serializer: ::SpreeCmCommissioner::V2::Storefront::AssetSerializer
        has_one :app_banner, serializer: ::SpreeCmCommissioner::V2::Storefront::AssetSerializer
        has_one :web_banner, serializer: ::SpreeCmCommissioner::V2::Storefront::AssetSerializer
        has_one :home_banner, serializer: ::SpreeCmCommissioner::V2::Storefront::AssetSerializer
      end
    end
  end
end
