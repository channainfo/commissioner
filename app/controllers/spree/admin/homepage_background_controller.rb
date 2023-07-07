module Spree
  module Admin
    class HomepageBackgroundController < Spree::Admin::ResourceController
      before_action :build_images, only: :create
      before_action :create_images, only: :update

      def build_images
        @object.build_app_image(attachment: permitted_resource_params.delete(:app_image)) if permitted_resource_params[:app_image]
        @object.build_web_image(attachment: permitted_resource_params.delete(:web_image)) if permitted_resource_params[:web_image]
      end

      def create_images
        @object.build_app_image(attachment: permitted_resource_params.delete(:app_image)) if permitted_resource_params[:app_image]
        @object.build_web_image(attachment: permitted_resource_params.delete(:web_image)) if permitted_resource_params[:web_image_image]
      end

      def model_class
        SpreeCmCommissioner::HomepageBackground
      end

      def object_name
        'spree_cm_commissioner_homepage_background'
      end

      def collection_url(options = {})
        admin_homepage_feed_homepage_background_index_url(options)
      end

      private

      def collection
        return @collection if defined?(@collection)

        params[:q] = {} if params[:q].blank?

        @collection = super.order(priority: :asc)
        @search = @collection.ransack(params[:q])

        @collection = @search.result.page(params[:page]).per(params[:per_page])
      end
    end
  end
end
