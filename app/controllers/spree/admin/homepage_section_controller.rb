module Spree
  module Admin
    class HomepageSectionController < Spree::Admin::ResourceController
      include SpreeCmCommissioner::Admin::HomepageSegmentHelper
      helper_method :badge_class_for_segment

      def model_class
        SpreeCmCommissioner::HomepageSection
      end

      def object_name
        'spree_cm_commissioner_homepage_section'
      end

      def collection_url
        admin_homepage_feed_homepage_section_index_url
      end

      def edit
        homepage_section_id = params[:id]
        @homepage_section = SpreeCmCommissioner::HomepageSection.find(homepage_section_id)
        @homepage_section_relatables = SpreeCmCommissioner::HomepageSectionRelatable.where(homepage_section: @homepage_section)
      end

      def location_after_save
        if @object.homepage_section_relatables_count.positive?
          collection_url
        else
          edit_admin_homepage_feed_homepage_section_url(@object)
        end
      end

      private

      def collection
        return @collection if defined?(@collection)

        params[:q] = {} if params[:q].blank?

        @collection = super.order(position: :asc)
        @search = @collection.ransack(params[:q])

        @collection = @search.result
                             .page(params[:page])
                             .per(params[:per_page])
      end

      # overrided
      def permitted_resource_params
        segment_value = calculate_segment_value(params[:spree_cm_commissioner_homepage_section])

        params.require(:spree_cm_commissioner_homepage_section).permit(:title, :description, :active).merge(segment: segment_value)
      end
    end
  end
end
