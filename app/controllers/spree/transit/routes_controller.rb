module Spree
  module Transit
    class RoutesController < Spree::Transit::BaseController
      before_action :load_data

      def scope
        current_vendor.products.where(product_type: :transit)
      end

      def show
        redirect_to spree.edit_transit_route_path(@route)
      end

      def load_data
        @route = @object
        @option_types = OptionType.order(:name)
        @shipping_categories = ShippingCategory.order(:name)
        @selected_option_type_ids = Spree::OptionType.where(name: %w[origin destination]).ids
      end

      def collection
        return @collection if defined?(@collection)

        current_vendor.products.where(product_type: :transit)

        @search = current_vendor.products.where(product_type: :transit).ransack(params[:q])
        @collection = @search.result
      end

      # overrided
      def find_resource
        current_vendor.products.find_by(slug: params[:id])
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
