module Spree
  module V2
    module Billing
      class VariantSerializer < Spree::V2::Storefront::BaseSerializer
        attributes :id, :name, :product_id, :sku, :price
      end
    end
  end
end
