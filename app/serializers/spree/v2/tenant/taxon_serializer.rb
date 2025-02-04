module Spree
  module V2
    module Tenant
      class TaxonSerializer < BaseSerializer
        attributes :name, :pretty_name, :permalink, :seo_title, :description,
                   :meta_title, :meta_description, :meta_keywords, :left, :right,
                   :position, :depth, :updated_at, :public_metadata

        attributes :custom_redirect_url, :kind, :subtitle, :from_date, :to_date,
                   :background_color, :foreground_color, :show_badge_status,
                   :purchasable_on

        has_one :category_icon, serializer: ::Spree::V2::Tenant::AssetSerializer
        has_one :app_banner, serializer: ::Spree::V2::Tenant::AssetSerializer
        has_one :web_banner, serializer: ::Spree::V2::Tenant::AssetSerializer
        has_one :home_banner, serializer: ::Spree::V2::Tenant::AssetSerializer

        attribute :is_root, &:root?

        attribute :is_child, &:child?

        attribute :is_leaf, &:leaf?

        belongs_to :parent,   record_type: :taxon, serializer: :taxon
        belongs_to :taxonomy, record_type: :taxonomy

        has_many   :children, record_type: :taxon, serializer: :taxon
      end
    end
  end
end
