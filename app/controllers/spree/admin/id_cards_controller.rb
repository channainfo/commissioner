module Spree
  module Admin
    class IdCardsController < Spree::Admin::ResourceController
      before_action :build_images, only: :create
      before_action :create_images, only: :update

      def model_class
        SpreeCmCommissioner::IdCard
      end

      def collection_url
        spree.admin_order_guests_url(params[:order_id])
      end

      def object_name
        'spree_cm_commissioner_id_card'
      end

      def build_images
        @object.build_front_image(attachment: permitted_resource_params.delete(:front_image)) if permitted_resource_params[:front_image]
        @object.build_back_image(attachment: permitted_resource_params.delete(:back_image)) if permitted_resource_params[:back_image]
      end

      def create_images
        @object.build_front_image(attachment: permitted_resource_params.delete(:front_image)) if permitted_resource_params[:front_image]

        @object.build_back_image(attachment: permitted_resource_params.delete(:back_image)) if permitted_resource_params[:back_image]
      end
    end
  end
end
