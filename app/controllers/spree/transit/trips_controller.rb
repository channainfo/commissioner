module Spree
  module Transit
    class TripsController < Spree::Transit::BaseController
      before_action :load_data

      def load_data
        @product = Spree::Product.find_by(slug: params[:route_id])
        @vehicles = SpreeCmCommissioner::Vehicle.includes(:vehicle_type).order('cm_vehicle_types.name')
        @stops = Spree::Taxonomy.place.taxons.select(&:stop?).to_a
        @places = Spree::Taxonomy.place.taxons.select(&:location?).to_a
        @trip = SpreeCmCommissioner::Trip.find_by(id: params[:id]) if params[:id]
      end

      def model_class
        SpreeCmCommissioner::Trip
      end

      def edit
        @boarding_stops = @trip.trip_stops.boarding.to_a.pluck(:stop_id)
        @drop_off_stops = @trip.trip_stops.drop_off.to_a.pluck(:stop_id)
      end

      def create
        @trip = model_class.new
        if @trip.update(trip_params(nested_stop_attributes))
          flash[:success] = flash_message_for(@trip, :successfully_created)
          redirect_back(fallback_location: edit_transit_route_trip_path(@product, @trip))
        else
          byebug
          flash[:error] = "create failed. Errors: #{@trip.errors.full_messages.join(', ')}"
          redirect_back(fallback_location: new_transit_route_trip_path(@product))
        end
      end

      def update
        if @trip.update(trip_params(nested_stop_attributes))
          flash[:success] = flash_message_for(@trip, :successfully_updated)
        else
          flash[:error] = "update failed. Errors: #{@trip.errors.full_messages.join(', ')}"
        end
        redirect_back(fallback_location: edit_transit_route_trip_path(@product, @trip))
      end

      def nested_stop_attributes
        cm_params = params.require('spree_cm_commissioner_trip')
        trip_stops = @trip.trip_stops.index_by(&:stop_id)

        boarding_points_attributes = (cm_params.delete('boarding_points') || []).compact_blank
                                                                                .map do |point_id|
          trip_stop = trip_stops.delete(point_id.to_i)
          { stop_id: point_id, stop_type: 'boarding', id: trip_stop.try(:id) }
        end

        drop_off_points_attributes = (cm_params.delete('drop_off_points') || []).compact_blank
                                                                                .map do |point_id|
          trip_stop = trip_stops.delete(point_id.to_i)
          { stop_id: point_id, stop_type: 'drop_off', id: trip_stop.try(:id) }
        end

        trip_stops.each_value do |trip_stop|
          next unless trip_stop.stop_id != @trip.origin_id && trip_stop.stop_id != @trip.destination_id

          boarding_points_attributes << { id: trip_stop.id,
                                          _destroy: '1'
}
        end

        cm_params[:trip_stops_attributes] = boarding_points_attributes + drop_off_points_attributes
        cm_params
      end

      def trip_params(params)
        params.permit(
          :origin_id, :destination_id, :vehicle_id, :hours, :minutes, :seconds,
          'departure_time(1i)', 'departure_time(2i)', 'departure_time(3i)',
          'departure_time(4i)', 'departure_time(5i)', :product_id,
          trip_stops_attributes: %i[stop_id stop_type _destroy id]
        )
      end

      def object_name
        'spree_cm_commissioner_trip'
      end

      def location_after_save
        transit_routes_path
      end
    end
  end
end
