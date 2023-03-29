module Spree
  module Admin
    module VendorsControllerDecorator
      def self.prepended(base)
        base.before_action :build_logo, only: %i[create update]
        base.before_action :contruct_nearby_place, only: %i[create update]
      end

      private

      def contruct_nearby_place
        return unless permitted_resource_params.key?(:nearby_places_attributes)

        nearby_places_attributes = {}
        permitted_resource_params[:nearby_places_attributes].each do |id, vendor_place_attributes|
          nearby_places_attributes[id] = vendor_place_attributes.except(:selected) if
          vendor_place_attributes[:selected] == 'true'
        end
        permitted_resource_params[:nearby_places_attributes] = nearby_places_attributes
      end

      def build_logo
        return unless permitted_resource_params[:logo]

        @vendor.build_logo(attachment: permitted_resource_params.delete(:logo))
      end
    end
  end
end

Spree::Admin::VendorsController.prepend(Spree::Admin::VendorsControllerDecorator)
