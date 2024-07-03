module Spree
  module Admin
    class HotelGoogleWalletsController < Spree::Admin::ResourceController
      before_action :product

      # POST /google_wallets
      def create
        wallet = model_class.new(product_id: product.id, review_status: permitted_resource_params[:review_status])
        if wallet.save
          redirect_to edit_admin_product_hotel_google_wallet_path(product, wallet.id)
        else
          render :new
        end
      end

      # POST /google_wallets/:id/create_google_wallet_class
      def create_google_wallet_class
        service = object.class_creator.call
        if service[:status] == '200'
          redirect_to location_after_save, notice: I18n.t('google_wallet.google_wallet_class_created')
        else
          redirect_to location_after_save, alert: I18n.t('google_wallet.google_wallet_class_create_fail')
        end
      end

      # PATCH /google_wallets/:id/update_google_wallet_class
      def update_google_wallet_class
        service = object.class_updater.call
        if service[:status] == '200'
          redirect_to location_after_save, notice: I18n.t('google_wallet.google_wallet_class_updated')
        else
          redirect_to location_after_save, alert: I18n.t('google_wallet.google_wallet_class_update_fail')
        end
      end

      # DELETE /hotel_google_wallets/:id/remove_logo
      def remove_logo
        object.logo.purge
      end

      # DELETE /hotel_google_wallets/:id/remove_hero_image
      def remove_hero_image
        object.hero_image.purge
      end

      private

      def product
        @product ||= Spree::Product.find_by(slug: params[:product_id])
      end

      def object
        @object ||= product.google_wallet
      end

      def object_name
        'spree_cm_commissioner_hotel_google_wallet'
      end

      # @overrided
      def model_class
        SpreeCmCommissioner::HotelGoogleWallet
      end

      def location_after_save
        edit_admin_product_hotel_google_wallet_path(product, object.id)
      end

      # @overrided
      def collection_url(options = {})
        admin_product_hotel_google_wallets_url(options)
      end

      def permitted_resource_params
        params.require(object_name).permit(:review_status, :logo, :hero_image)
      end
    end
  end
end
