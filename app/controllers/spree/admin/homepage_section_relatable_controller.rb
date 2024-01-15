module Spree
  module Admin
    class HomepageSectionRelatableController < Spree::Admin::ResourceController
      def model_class
        SpreeCmCommissioner::HomepageSectionRelatable
      end

      # @overrided
      def load_resource_instance
        return model_class.new(homepage_section_id: params[:homepage_section_id]) if new_actions.include?(action)

        model_class.find(params[:id])
      end

      def object_name
        'spree_cm_commissioner_homepage_section_relatable'
      end

      def collection_url(options = {})
        admin_homepage_feed_homepage_section_relatable_index_url(options)
      end

      def location_after_save
        edit_admin_homepage_feed_homepage_section_url(@object.homepage_section_id)
      end

      def permitted_resource_params
        params.require(object_name).permit(:homepage_section_id, :relatable_id, :relatable_type, :active)
      end
    end
  end
end
