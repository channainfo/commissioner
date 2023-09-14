module Spree
  module Transit
    class StopsController < Spree::Transit::BaseController
      before_action :load_location

      def index
        @stops = SpreeCmCommissioner::Stop.order(:name)
      end

      def collection
        load_location
        return [] if current_vendor.blank?
        return @collection if defined?(@collection)

        @search = @locations.ransack(params[:q])
        @collection = @search.result
      end

      def load_location
        @locations = Spree::State.all
      end

      def location_after_save
        transit_stops_url
      end

      def model_class
        SpreeCmCommissioner::Stop
      end

      def object_name
        'spree_cm_commissioner_stop'
      end
    end
  end
end
