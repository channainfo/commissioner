module Spree
  module Admin
    class NearbyPlacesController < Spree::Admin::ResourceController
      before_action :load_vendor

      def index
        @nearby_places = @vendor.nearby_places
      end

      def new
        @name = params[:name]
        context = SpreeCmCommissioner::VendorNearbyPlaceBuilder.call(vendor: @vendor, name: @name)
        @nearby_places = context.nearby_places.sort_by(&:distance)
      end

      def model_class
        SpreeCmCommissioner::VendorPlace
      end

      def object_name
        'spree_cm_commissioner_nearby_places'
      end

      def collection_url(options = {})
        admin_vendor_nearby_places_url(options)
      end

      def permitted_resource_params
        params.permit(nearby_places: %i[name reference lat lon vicinity icon url rating formatted_address address_components])
      end

      private

      def load_vendor
        @vendor ||= Spree::Vendor.find_by(slug: params[:vendor_id])
      end
    end
  end
end
