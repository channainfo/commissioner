module Spree
  module Transit
    class VehicleSeatsController < Spree::Transit::BaseController

      def create

      end

      def load_seat
        @seats = JSON.parse(params[:seats]).to_a
        render :partial => 'spree/transit/vehicle_seats/seats'
      end

      private

      def model_class
        SpreeCmCommissioner::VehicleSeat
      end
      def object_name
        'spree_cm_commissioner_vehicle_seat'
      end
    end
  end
end