module Spree
  module Transit
    class TripsController < Spree::Transit::BaseController
      before_action :load_data

      def load_data
        @product = Spree::Product.find_by(slug: params[:route_id])
        @vehicles = SpreeCmCommissioner::Vehicle.includes(:vehicle_type).order('cm_vehicle_types.name')
        @points = Spree::Taxonomy.place.taxons.select(&:point?).to_a
        @trip = SpreeCmCommissioner::Trip.find_by(id: params[:id]) if params[:id]
      end

      def collection_url(options = {})
        transit_routes_path(options)
      end

      def model_class
        SpreeCmCommissioner::Trip
      end

      # def new
      #   @trip = Trip.new
      #   @trip.trip_points.build(point_type: 'boarding')
      #   @trip.trip_points.build(point_type: 'drop_off')
      # end

      def edit
        @boarding_points = @trip.trip_points.boarding.to_a.pluck(:point_id)
        @drop_off_points = @trip.trip_points.drop_off.to_a.pluck(:point_id)
      end

      # def create
      #   @trip = model_class.new(trip_params)

      #   if @trip.save
      #     redirect_to location_after_save
      #   else
      #     render :new
      #   end
      # end

      def update
        cm_params = params.require('spree_cm_commissioner_trip').permit(
          :origin_id, :destination_id, :vehicle_id, :hours, :minutes, :seconds,
          'departure_time(1i)', 'departure_time(2i)', 'departure_time(3i)',
          'departure_time(4i)', 'departure_time(5i)', :product_id,
          boarding_points: [], drop_off_points: []
        )

        # Transform boarding_points and drop_off_points to trip_points_attributes format
        boarding_points_attributes = (cm_params.delete('boarding_points') || []).compact_blank
                                                                                .map { |point_id| { point_id: point_id, point_type: 'boarding' } }
        drop_off_points_attributes = (cm_params.delete('drop_off_points') || []).compact_blank
                                                                                .map { |point_id| { point_id: point_id, point_type: 'drop_off' } }

        # Merge the transformed points into trip_points_attributes
        @trip.trip_points.find_or_create_by
        cm_params[:trip_points_attributes] = boarding_points_attributes + drop_off_points_attributes

        # Now, use a method that specifically permits trip_points_attributes and any other necessary parameters
        nil unless @trip.update(trip_params(cm_params))
      end

      private

      def trip_params(params)
        params.permit(
          :origin_id, :destination_id, :vehicle_id, :hours, :minutes, :seconds,
          'departure_time(1i)', 'departure_time(2i)', 'departure_time(3i)',
          'departure_time(4i)', 'departure_time(5i)', :product_id,
          trip_points_attributes: %i[point_id point_type _destroy id]
        )
      end

      # def permitted_trip_attributes
      #   trip_params = params['spree_cm_commissioner_trip']
      # end

      # def update
      #   byebug
      # end

      def location_after_save
        transit_routes_url
      end

      def object_name
        'spree_cm_commissioner_trip'
      end
    end
  end
end
