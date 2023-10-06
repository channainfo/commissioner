module Spree
  module Transit
    class VehicleTypesController < Spree::Transit::BaseController

      def index

      end

      def location_after_save
        transit_vehicle_types_url
      end

      def new
        @vehicle_type = SpreeCmCommissioner::VehicleType.new
        @vehicleSeat = SpreeCmCommissioner::VehicleSeat.new
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