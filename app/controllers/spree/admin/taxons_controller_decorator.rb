module Spree
  module Admin
    module TaxonsControllerDecorator
      def self.prepended(base)
        base.before_action :build_category_icon, only: %i[create update]
      end

      def remove_category_icon
        if @taxon.category_icon.destroy
          flash[:success] = Spree.t('notice_messages.icon_removed')
          redirect_to spree.edit_admin_taxonomy_taxon_url(@taxonomy.id, @taxon.id)
        else
          flash[:error] = Spree.t('errors.messages.cannot_remove_icon')
          render :edit, status: :unprocessable_entity
        end
      end

      private

      def build_category_icon
        return unless permitted_resource_params[:category_icon]

        @taxon.build_category_icon(attachment: permitted_resource_params.delete(:category_icon))
      end
    end
  end
end

Spree::Admin::TaxonsController.prepend(Spree::Admin::TaxonsControllerDecorator)
