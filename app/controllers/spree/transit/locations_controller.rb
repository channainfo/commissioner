module Spree
  module Transit
    class LocationsController < Spree::Transit::BaseController
      def load_location
        @locations = Spree::State.all
      end

      def load_country
        @countries = Spree::Country.where(id: current_vendor.default_country)
      end

      def new
        @object.country_id = Spree::Country.find_by(id: current_vendor.default_country)&.id
      end

      def collection
        return @collection if defined?(@collection)

        load_location

        @search = @locations.ransack(params[:q])
        @collection = @search.result
      end

      def location_after_save
        transit_locations_url
      end

      def model_class
        Spree::State
      end

      def object_name
        'state'
      end
    end
  end
end
