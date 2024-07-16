module Spree
  module Admin
    class VideoOnDemandsController < Spree::Admin::ResourceController
      before_action :load_parent
      before_action :load_video_on_demands, only: %i[index new edit]
      before_action :build_thumbnails, only: :create
      before_action :create_thumbnails, only: :update

      def build_thumbnails
        @object.build_thumbnail(attachment: permitted_resource_params.delete(:thumbnail)) if permitted_resource_params[:thumbnail]
      end

      def create_thumbnails
        @object.create_thumbnail(attachment: permitted_resource_params.delete(:thumbnail)) if permitted_resource_params[:thumbnail]
      end

      def edit
        @video_on_demand = SpreeCmCommissioner::VideoOnDemand.find(params[:id])
      end

      def create
        video_on_demand_params = params.require(:spree_cm_commissioner_video_on_demand)
        result = SpreeCmCommissioner::VideoOnDemandCreator.call(video_on_demand_params: video_on_demand_params)

        if result.success?
          redirect_to collection_url
        else
          flash[:error] = result.error
          render :new
        end
      end

      def update
        @video_on_demand = SpreeCmCommissioner::VideoOnDemand.find(params[:id])
        result = SpreeCmCommissioner::VideoOnDemandUpdater.call(video_on_demand: @video_on_demand, params: params)

        if result.success?
          redirect_to collection_url
        else
          flash[:error] = result.error
          render :edit
        end
      end

      private

      def model_class
        SpreeCmCommissioner::VideoOnDemand
      end

      def object_name
        'spree_cm_commissioner_video_on_demand'
      end

      def collection_url(options = {})
        admin_product_video_on_demands_url(options)
      end

      def load_parent
        @product ||= Spree::Product.find_by(slug: params[:product_id])
      end

      def load_video_on_demands
        @variants = @product.variants.includes(:video_on_demand)
        @video_on_demands = @product.variants.includes(:video_on_demand).map(&:video_on_demand).compact
      end
    end
  end
end
