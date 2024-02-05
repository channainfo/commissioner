module Spree
  module Admin
    class HomepageSectionController < Spree::Admin::ResourceController
      def model_class
        SpreeCmCommissioner::HomepageSection
      end

      def object_name
        'spree_cm_commissioner_homepage_section'
      end

      def collection_url(options = {})
        admin_homepage_feed_homepage_section_index_url(options)
      end

      # ovverride
      def edit
        homepage_section_id = params[:id]
        @homepage_section = SpreeCmCommissioner::HomepageSection.find(homepage_section_id)
        @homepage_section_relatables = SpreeCmCommissioner::HomepageSectionRelatable.where(homepage_section: @homepage_section)
      end

      # This method update the updated_at field of all homepage sections
      def update_the_updated_at
        SpreeCmCommissioner::HomepageSection.find_each(&:touch)

        redirect_to collection_url
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
    end
  end
end
