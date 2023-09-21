module Spree
  module Transit
    class RoutesController < Spree::Transit::BaseController
      before_action :load_data, except: :index

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
        @selected_option_type_ids = Spree::OptionType.where(name: %w[origin destination route-type]).ids
      end

      def collection
        return @collection if defined?(@collection)

        @search = scope.ransack(params[:q])
        @collection = @search.result.page(page).per(per_page)
      end


      # overrided
      def find_resource
        product_scope.with_deleted.friendly.find(params[:id])
      end

      def product_scope
        current_store.products.accessible_by(current_ability, :index)
      end

      def new
        @route.product_type = :transit
      end

      def location_after_save
        edit_transit_route_url(@route.id)
      end

      def variant_stock_includes
        [:images, { stock_items: :stock_location, option_values: :option_type }]
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
