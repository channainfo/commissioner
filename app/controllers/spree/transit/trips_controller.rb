module Spree
  module Transit
    class TripsController < Spree::Transit::BaseController
      before_action :load_data

      def load_data
        @product = Spree::Product.find_by(slug: params[:route_id])
        @vehicles = current_vendor.vehicles.includes(:vehicle_type).order('cm_vehicle_types.name')
      end

      def collection_url(options = {})
        transit_routes_path(options)
      end

      def model_class
        SpreeCmCommissioner::Trip
      end

      def location_after_save
        transit_routes_url
      end

      def object_name
        'spree_cm_commissioner_trip'
      end
    end
  end
end
