module Spree
  module Transit
    class VehicleTypesController < Spree::Transit::BaseController
      def index; end

      def location_after_save
        transit_vehicle_types_url
      end

      def layer
        @seats = JSON.parse(params[:seats]).to_a
        @row = params[:row]
        @column = params[:column]
        @layer_name = params[:layer_name]
        render :partial => 'spree/transit/vehicle_types/seat_view'
      end

      def new
        @vehicle_type = SpreeCmCommissioner::VehicleType.new
      end

      def edit
        @seats = @object.seat_layers
      end

      def save_seat_layer
        redirect_to transit_vehicle_type_url
      end

      # @overrided
      def model_class
        SpreeCmCommissioner::VehicleType
      end

      def object_name
        'spree_cm_commissioner_vehicle_type'
      end
    end
  end
end
