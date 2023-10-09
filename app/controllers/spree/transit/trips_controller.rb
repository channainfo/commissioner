module Spree
  module Transit
    class TripsController < Spree::Transit::BaseController
      before_action :load_route, only: [:index, :new, :create, :edit]
      before_action :load_resource_instance, only: [:new]
      before_action :new_stop_time, only: [:new]
      def load_route
        @route ||= Spree::Product.find_by!(id: params[:route_id])
      end

      def scope
        load_route
        @route.variants
      end

      def new_stop_time
        @variant.stop_times.build
      end

      def collection
        return @collection if @collection.present?

        params[:q] ||= {}
        @deleted = params[:q].delete(:deleted_at_null) || '0'
        @collection = super
        @collection = @collection.deleted if @deleted == '1'
        @search = @collection.ransack(params[:q])
        @collection = @search.result.
                      page(params[:page]).
                      per(params[:per_page] || Spree::Backend::Config[:variants_per_page])
      end

      def load_resource_instance
        return scope.new if new_actions.include?(action)
        scope.find_by!(id: params[:id])
      end

      def location_after_save
       transit_route_trips_url
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
