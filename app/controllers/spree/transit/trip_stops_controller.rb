module Spree
  module Transit
    class TripStopsController < Spree::Transit::BaseController
      before_action :load_data
      def index; end

      def load_data
        @product = Spree::Product.find_by(slug: params[:route_id])
        @trip = SpreeCmCommissioner::Trip.find_by(id: params[:trip_id]) if params[:trip_id]
        @trip_stops = @trip.trip_stops.sort_by(&:sequence)
      end

      def update_sequences
        ApplicationRecord.transaction do
          params[:positions].each do |id, index|
            SpreeCmCommissioner::TripStop.where(id: id).update(sequence: index)
          end
        end

        respond_to do |format|
          format.html { redirect_to transit_route_trip_trip_stops_path(@product, @product.trip) }
          format.js { render plain: 'Ok' }
        end
      end

      def object_name
        'spree_cm_commissioner_trip_stop'
      end

      def model_class
        SpreeCmCommissioner::TripStop
      end
    end
  end
end
