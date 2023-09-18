module Spree
  module Transit
    class RoutesController < Spree::Transit::BaseController
      before_action :load_data

      def load_data
        @option_types = OptionType.order(:name)
        @shipping_categories = ShippingCategory.order(:name)
        @selected_option_type_ids = Spree::OptionType.where(name: %w[origin destination route-type]).ids
      end

      def collection
        return @collection if defined?(@collection)
        current_vendor.products.where(product_type: :transit)

        @search = current_vendor.products.where(product_type: :transit).ransack(params[:q])
        @collection = @search.result
      end

      # overrided
      def find_resource
        scope.find_by(slug: params[:id])
      end

      def new
        @object.product_type = :transit
      end

      def location_after_save
        transit_routes_url
      end

      def model_class
        Spree::Product
      end

      def object_name
        'product'
      end
    end
  end
end
