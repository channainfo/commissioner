module Spree
  module Admin
    class StockManagementsController < Spree::Admin::ResourceController
      skip_before_action :load_resource

      before_action :load_parent

      def load_parent
        @product = Spree::Product.find_by(slug: params[:product_id])
      end

      def index
        @variants = @product.variants.includes(:images, stock_items: :stock_location, option_values: :option_type)
        @variants = [@product.master] if @variants.empty?

        @stock_locations = (@variants.flat_map(&:stock_locations) + @product.vendor.stock_locations).uniq
      end

      def model_class
        Spree::StockItem
      end
    end
  end
end
