module Spree
  module Admin
    class NearbyPlacesController < Spree::Admin::ResourceController
      before_action :load_vendor

      def index
        @nearby_places = @vendor.promoted_nearby_places
      end

      def new
        @nearby_places = @vendor.nearby_places
      end

      private

      def load_vendor
        @vendor ||= Spree::Vendor.find_by(slug: params[:vendor_id])
        @object ||= @vendor
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
        nearby_places = []
        promoted_nearby_place_ids = params['vendor']['promoted_nearby_place_ids']
        promoted_nearby_place_ids = promoted_nearby_place_ids.map(&:to_i)

        @vendor.nearby_places.each do |nearby_place|
          nearby_place.promoted = promoted_nearby_place_ids.include?(nearby_place.place_id)
          nearby_place.save
          nearby_places << nearby_place
        end

        { nearby_places: nearby_places }
      end
    end
  end
end
