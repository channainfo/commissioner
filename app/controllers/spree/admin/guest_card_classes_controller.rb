module Spree
  module Admin
    class GuestCardClassesController < Spree::Admin::ResourceController
      before_action :load_taxonomy_taxon
      before_action :build_assets, only: :update

      def index
        @guest_card_classes = @taxon.guest_card_classes
      end

      # DELETE /remove_background_image
      def remove_background_image
        remove_asset(@object.background_image)
      end

      private

      def remove_asset(asset)
        if asset.destroy
          flash[:success] = Spree.t('notice_messages.icon_removed')
          redirect_to spree.edit_admin_taxonomy_taxon_guest_card_class_url(@taxonomy.id, @taxon.id, @object.id)
        else
          flash[:error] = Spree.t('errors.messages.cannot_remove_icon')
          render :edit, status: :unprocessable_entity
        end
      end

      def build_assets
        return unless @object.is_a?(SpreeCmCommissioner::GuestCardClasses::BibCardClass)
        return unless permitted_resource_params[:background_image]

        @object.build_background_image(attachment: permitted_resource_params.delete(:background_image))
      end

      def load_taxonomy_taxon
        @taxonomy = Spree::Taxonomy.find(params[:taxonomy_id])
        @taxon = @taxonomy.taxons.find(params[:taxon_id])
      end

      def model_class
        SpreeCmCommissioner::GuestCardClass
      end

      def object_name
        'spree_cm_commissioner_guest_card_class'
      end

      def collection_url
        admin_taxonomy_taxon_guest_card_classes_url
      end

      # override
      def location_after_save
        if @object.is_a?(SpreeCmCommissioner::GuestCardClasses::BibCardClass) && @object.background_image
          admin_taxonomy_taxon_guest_card_classes_path(@taxonomy.id, @taxon.id, @object.id)
        else
          edit_admin_taxonomy_taxon_guest_card_class_path(@taxonomy.id, @taxon.id, @object.id)
        end
      end

      # override
      # permit all attributes for now.
      def permitted_resource_params
        @permitted_resource_params ||= begin
          key = ActiveModel::Naming.param_key(@object)
          params.require(key).permit(
            :name,
            :type,
            :taxon_id,
            :preferred_background_color,
            :background_image
          )
        end
      end
    end
  end
end
