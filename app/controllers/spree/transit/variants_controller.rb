module Spree
  module Transit
    class VariantsController < Spree::Transit::BaseController
      before_action :load_route, only: [:index, :new, :create, :edit, :update]
      before_action :load_resource_instance, only: [:new]

      def load_route
        @route ||= Spree::Product.find_by!(id: params[:route_id])
        @origin_option_type = Spree::OptionType.find_by(name: 'origin')
        @destination_option_type = Spree::OptionType.find_by(name: 'destination')
      end

      def scope
        load_route
        @route.variants
      end

      def collection
        return @collection if defined?(@collection)
        @collection = super
        @search = scope.ransack(params[:q])
        @collection = @search.result.page(page).per(per_page)
      end

      def load_resource_instance
        return scope.new if new_actions.include?(action)
        scope.find_by!(id: params[:id])
      end

      def location_after_save
       transit_route_variants_url
      end

      def model_class
        Spree::Variant
      end

      def object_name
        'variant'
      end

    end
  end
end
