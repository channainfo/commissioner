module Spree
  module Transit
    class VehiclePhotosController < Spree::Transit::BaseController
      prepend_before_action :load_vehicle

      create.before :set_viewable
      update.before :set_viewable

      def index; end

      def load_vehicle
        @vehicle ||= current_vendor.vehicles.find(params[:vehicle_id])
      end

      def set_viewable
        @object.viewable_type = viewable_type
        @object.viewable_id = viewable_id
      end

      def viewable_type
        @vehicle.class.name
      end

      def viewable_id
        @vehicle.id
      end

      def collection
        @objects = model_class.where(
          viewable_type: viewable_type,
          viewable_id: viewable_id
        )
      end

      def location_after_save
        transit_vehicle_vehicle_photos_url
      end

      def model_class
        SpreeCmCommissioner::VehiclePhoto
      end

      def object_name
        'spree_cm_commissioner_vehicle_photo'
      end

      def collection_url(options = {})
        transit_vehicle_vehicle_photos_url(options)
      end
    end
  end
end
