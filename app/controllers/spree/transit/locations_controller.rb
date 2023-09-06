module Spree
  module Transit
    class LocationsController < Spree::Transit::BaseController
      before_action :load_location

      def load_location
        @locations = Spree::State.where(country_id: Spree::Country.find_by(iso: 'KH'))
      end

      def collection
        load_location
        return [] if current_vendor.blank?
        return @collection if defined?(@collection)

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
