module SpreeCmCommissioner
  module Feed
    class VendorIncludeProduct
      include ActiveModel::Serialization

      attr_accessor :id, :name, :slug, :app_promotion_banner_id, :app_promotion_banner, :products, :product_ids

      def initialize(vendor:, products:)
        @id = vendor.id
        @name = vendor.name
        @slug = vendor.slug
        @app_promotion_banner_id = vendor.app_promotion_banner_id
        @app_promotion_banner = vendor.app_promotion_banner

        @products = products
        @product_ids = products.map(&:id)
      end
    end
  end
end
