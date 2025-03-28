module Spree
  module V2
    module Storefront
      class ActiveHomepageEventSerializer < BaseSerializer
        attributes :name, :pretty_name, :permalink, :seo_title,
                   :description, :meta_title, :meta_description, :meta_keywords,
                   :depth, :updated_at, :custom_redirect_url, :kind,
                   :subtitle, :from_date, :to_date

        attribute  :is_root, &:root?
        attribute  :is_child, &:child?
        attribute  :is_leaf, &:leaf?

        has_one    :category_icon, serializer: ::SpreeCmCommissioner::V2::Storefront::AssetSerializer
      end
    end
  end
end
