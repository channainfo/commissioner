module Spree
  module Admin
    class GoogleWalletsController < Spree::Admin::ResourceController
      skip_before_action :load_resource
      before_action :product, :object
      update.before :clear_verify_status

      helper 'spree/admin/google_wallets'

      # POST /google_wallets/:id/verify_with_google
      def verify_with_google
        if object.preferred_response.blank?
          create_google_wallet_class
        else
          update_google_wallet_class
        end
      end

      # DELETE /google_wallets/:id/remove_logo
      def remove_logo
        object.logo.purge
      end

      # DELETE /google_wallets/:id/remove_hero_image
      def remove_hero_image
        object.hero_image.purge
      end

      private

      def product
        @product ||= Spree::Product.find_by(slug: params[:product_id])
      end

      def object
        @object ||= if new_actions.include?(action)
                      model_class.new(product_id: product.id)
                    elsif params[:id]
                      product.google_wallet
                    end
      end

      def clear_verify_status
        permitted_resource_params[:preferred_verified_at] = nil
      end

      def object_name
        'spree_cm_commissioner_event_ticket_google_wallet'
      end

      def location_after_save
        edit_admin_product_google_wallet_path(product, object.id)
      end

      def create_google_wallet_class
        service = object.class_creator.call
        if service[:status] == '200'
          object.verify_create!(service[:status])
          redirect_to location_after_save, notice: I18n.t('google_wallet.google_wallet_class_created')
        else
          redirect_to location_after_save, alert: I18n.t('google_wallet.google_wallet_class_create_fail')
        end
      end

      def update_google_wallet_class
        service = object.class_updater.call
        if service[:status] == '200'
          object.verify!
          redirect_to location_after_save, notice: I18n.t('google_wallet.google_wallet_class_updated')
        else
          redirect_to location_after_save, alert: I18n.t('google_wallet.google_wallet_class_update_fail')
        end
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
