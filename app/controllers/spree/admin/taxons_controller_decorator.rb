module Spree
  module Admin
    module TaxonsControllerDecorator
      def self.prepended(base)
        base.before_action :build_assets, only: %i[create update]
      end

      def remove_category_icon
        remove_asset(@taxon.category_icon)
      end

      def remove_app_banner
        remove_asset(@taxon.app_banner)
      end

      def remove_web_banner
        remove_asset(@taxon.web_banner)
      end

      def remove_home_banner
        remove_asset(@taxon.home_banner)
      end

      private

      def taxon_params
        params.require(:taxon).permit(permitted_taxon_attributes, :preferred_background_color, :preferred_foreground_color)
      end

      def remove_asset(asset)
        if asset.destroy
          flash[:success] = Spree.t('notice_messages.icon_removed')
          redirect_to spree.edit_admin_taxonomy_taxon_url(@taxonomy.id, @taxon.id)
        else
          flash[:error] = Spree.t('errors.messages.cannot_remove_icon')
          render :edit, status: :unprocessable_entity
        end
      end

      def build_assets
        @taxon.build_category_icon(attachment: permitted_resource_params.delete(:category_icon)) if permitted_resource_params[:category_icon]
        @taxon.build_app_banner(attachment: permitted_resource_params.delete(:app_banner)) if permitted_resource_params[:app_banner]
        @taxon.build_web_banner(attachment: permitted_resource_params.delete(:web_banner)) if permitted_resource_params[:web_banner]
        @taxon.build_home_banner(attachment: permitted_resource_params.delete(:home_banner)) if permitted_resource_params[:home_banner]
      end
    end
  end
end

Spree::Admin::TaxonsController.prepend(Spree::Admin::TaxonsControllerDecorator)
