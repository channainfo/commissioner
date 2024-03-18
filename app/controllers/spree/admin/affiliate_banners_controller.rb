module Spree
  module Admin
    class AffiliateBannersController < Spree::Admin::BaseController
      before_action :set_affiliate_banner, only: %i[edit update destroy]

      def index
        @affiliate_banners = SpreeCmCommissioner::AffiliateBanner.page(params[:page]).order(id: :desc)
      end

      def new
        @affiliate_banner = SpreeCmCommissioner::AffiliateBanner.new
      end

      def edit; end

      def create
        @affiliate_banner = SpreeCmCommissioner::AffiliateBanner.new(permitted_resource_params)
        if @affiliate_banner.save
          redirect_to admin_affiliate_banners_path
        else
          render :new
        end
      end

      def update
        if @affiliate_banner.update(permitted_resource_params)
          redirect_to admin_affiliate_banners_path(page: params[:page], q: params[:q])
        else
          render :edit
        end
      end

      def destroy
        @affiliate_banner.toggle_status
        redirect_to admin_affiliate_banners_path
      end

      def model_class
        SpreeCmCommissioner::AffiliateBanner
      end

      def object_name
        'spree_cm_commissioner_affiliate_banner'
      end

      def collection_url
        admin_affiliate_banners_path
      end

      def set_affiliate_banner
        @affiliate_banner = SpreeCmCommissioner::AffiliateBanner.find(params[:id])
      end

      def affiliate_banner_params
        params.require(:affiliate_banner).permit(:name, :url, :banner, :banner_text, :description, :start_date, :end_date)
      end

      private

      def permitted_resource_params
        params.require(:spree_cm_commissioner_affiliate_banner).permit(:name, :url, :banner, :banner_text, :description, :start_date, :end_date)
      end
    end
  end
end
