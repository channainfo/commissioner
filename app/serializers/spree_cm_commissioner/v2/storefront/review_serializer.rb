module SpreeCmCommissioner
  module V2
    module Storefront
      class ReviewSerializer < BaseSerializer
        set_type :review

        attributes :rating, :title, :review, :name, :show_identifier, :created_at, :updated_at

        has_one :user, serializer: ::Spree::V2::Storefront::UserSerializer
        has_one :product, serializer: ::Spree::V2::Storefront::ProductSerializer
        has_many :images, serializer: SpreeCmCommissioner::V2::Storefront::AssetSerializer
      end
    end
  end
end
