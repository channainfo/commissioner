module Spree
  module Transit
    class VehiclesController < Spree::Transit::BaseController
      before_action :load_vehicle_types

      def new
        @vehicle = SpreeCmCommissioner::Vehicle.new
        super
      end

      def edit
        @vehicle = current_vendor.vehicles.find(params[:id])
      end

      def load_vehicle_types
        @vehicle_types = current_vendor.vehicle_types
      end

      def scope
        @vehicles = current_vendor.vehicles
      end

      def collection
        return @collection if defined?(@collection)
        scope

        @search = scope.includes(:vehicle_type).ransack(params[:q])
        @collection = @search.result
      end

      def location_after_save
        transit_vehicles_url
      end

      def model_class
        SpreeCmCommissioner::Vehicle
      end

      def object_name
        'spree_cm_commissioner_vehicle'
      end

      def vehicle_params
        params.require(:vehicle).permit(:code, :license_plate)
      end
    end
  end
end