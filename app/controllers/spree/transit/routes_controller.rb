module Spree
  module Transit
    class RoutesController < Spree::Transit::BaseController
      before_action :load_data, expect: :index

      def scope
        current_vendor.products.where(product_type: :transit)
      end

      def show
        redirect_to spree.edit_transit_route_path(@object)
      end

      def load_data
        @option_types = OptionType.order(:name)
        @shipping_categories = ShippingCategory.order(:name)
        @selected_option_type_ids = Spree::OptionType.where(name: %w[origin destination]).ids
        taxonomies = Spree::Taxonomy.where(kind: :transit)
        @taxons = taxonomies.map(&:taxons).flatten
      end

      def collection
        return @collection if defined?(@collection)

        params[:q] ||= {}
        params[:q][:deleted_at_null] ||= '1'

        params[:q][:s] ||= 'updated_at desc'

        current_vendor.products.where(product_type: :transit)

        @search = current_vendor.products.where(product_type: :transit).ransack(params[:q].reject { |k, _v| k.to_s == 'deleted_at_null' })

        @collection = @search.result
                      .page(params[:page])
                      .per(params[:per_page] || Spree::Backend::Config[:variants_per_page])
        @collection
      end

      # overrided
      def find_resource
        product_scope.with_deleted.friendly.find(params[:id])
      end

      def product_scope
        current_store.products.accessible_by(current_ability, :index)
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
