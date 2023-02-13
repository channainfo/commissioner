module Spree
  module Admin
    class NearbyPlacesController < Spree::Admin::ResourceController
      before_action :load_vendor

      def index
        @nearby_places = @vendor.nearby_places
      end

      def new
        SpreeCmCommissioner::NearbyPlaceCreator.call(params: permitted_resource_params , vendor: @vendor)
      end

      private

      def load_vendor
        @vendor ||= Spree::Vendor.find_by(slug: params[:vendor_id])
      end

      def model_class
        SpreeCmCommissioner::VendorPlace
      end

      def object_name
        'spree_cm_commissioner_nearby_places'
      end

      def resource_serializer
        Spree::V2::Storefront::NearbyPlaceSerializer
      end

      def collection_serializer
        Spree::V2::Storefront::NearbyPlaceSerializer
      end

      def collection_url(options = {})
        admin_vendor_nearby_places_url(options)
      end

      def permitted_resource_params
        params.permit(nearby_places: [:name, :reference, :lat, :lon, :vicinity, :icon, :url, :rating, :formatted_address, :address_components])
      end
    end
  end
end