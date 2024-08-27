module Spree
  module Admin
    class VideoOnDemandsController < Spree::Admin::ResourceController
      before_action :product
      before_action :load_video_on_demands, only: %i[index new edit create]

      def new
        uuid = SecureRandom.uuid.gsub('-', '')
        @object = SpreeCmCommissioner::VideoOnDemand.new(uuid: uuid)
      end

      def edit
        @video_on_demand = SpreeCmCommissioner::VideoOnDemand.find(params[:id])
      end

      def create
        video_on_demand_params = params.require(:spree_cm_commissioner_video_on_demand)
        result = SpreeCmCommissioner::VideoOnDemandCreator.call(video_on_demand_params: video_on_demand_params)
        if result.success?
          redirect_to edit_admin_product_video_on_demand_url(product, result.video_on_demand)
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

      def video_upload
        @video_on_demand = SpreeCmCommissioner::VideoOnDemand.find(params[:id])
        result = SpreeCmCommissioner::VideoOnDemandUpdater.call(video_on_demand: @video_on_demand, params: params)
        if result.success?
          redirect_to collection_url
        else
          flash[:error] = result.error
          render :edit
        end
      end

      def update_positions
        params[:positions].each do |id, index|
          video_on_demand = SpreeCmCommissioner::VideoOnDemand.find(id)
          video_on_demand.update(position: index)
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

      def product
        @product ||= Spree::Product.find_by(slug: params[:product_id])
      end

      def load_video_on_demands
        @video_on_demands = []
        @product.variants.each do |variant|
          @video_on_demands.concat(variant.video_on_demands.to_a)
        end

        @variants = @product.variants.map do |variant|
          [variant.options_text, variant.id]
        end

        return unless @product.use_video_as_default?

        video_on_demand = SpreeCmCommissioner::VideoOnDemand.where(variant_id: @product.master_id).to_a
        @variants.insert(0, [Spree.t(:default), @product.master_id])
        @video_on_demands.concat(video_on_demand)
      end
    end
  end
end
