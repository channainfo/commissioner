module Spree
  module Admin
    class GoogleWalletsController < Spree::Admin::ResourceController
      before_action :product
      before_action :build_assets, only: :update

      def create
        wallet = model_class.new(product_id: product.id, review_status: permitted_resource_params[:review_status])
        if wallet.save
          redirect_to edit_admin_product_google_wallet_path(product, wallet.id)
        else
          render :new
        end
      end

      # DELETE remove_logo_admin_product_google_wallet
      def remove_logo
        handle_asset(object.logo)
      end

      # DELETE remove_hero_image_admin_product_google_wallet
      def remove_hero_image
        handle_asset(object.hero_image)
      end

      private

      def product
        @product ||= Spree::Product.find_by(slug: params[:product_id])
      end

      def object
        @object ||= product.google_wallet
      end

      def build_assets
        object.build_logo(attachment: permitted_resource_params.delete(:logo)) if permitted_resource_params[:logo]
        object.build_hero_image(attachment: permitted_resource_params.delete(:hero_image)) if permitted_resource_params[:hero_image]
      end

      def handle_asset(asset)
        if asset.destroy
          redirect_to edit_admin_product_google_wallet_path(product, object.id)
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def object_name
        'spree_cm_commissioner_event_ticket_google_wallet'
      end

      def location_after_save
        edit_admin_product_google_wallet_path(product, object.id)
      end

      # @overrided
      def model_class
        SpreeCmCommissioner::EventTicketGoogleWallet
      end

      # @overrided
      def collection_url(options = {})
        admin_product_google_wallets_url(options)
      end
    end
  end
end
