module Spree
  module Admin
    class GuestCardClassesController < Spree::Admin::ResourceController
      before_action :load_taxonomy_taxon

      def index
        @guest_card_classes = @taxon.guest_card_classes
      end

      # DELETE /remove_background_image
      def remove_background_image
        remove_asset(@object.background_image)
      end

      def remove_asset(asset)
        if asset.destroy
          flash[:success] = Spree.t('notice_messages.icon_removed')
          redirect_to spree.edit_admin_taxonomy_taxon_guest_card_class_url(@taxonomy.id, @taxon.id, @object.id)
        else
          flash[:error] = Spree.t('errors.messages.cannot_remove_icon')
          render :edit, status: :unprocessable_entity
        end
      end

      private

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
        key = ActiveModel::Naming.param_key(@object)
        permit_keys = params.require(key).keys
        params.require(key).permit(permit_keys)
      end
    end
  end
end
