module Spree
  module Transit
    class TaxonomiesController < Spree::Transit::BaseController
      before_action :load_data
      helper 'spree/transit/sortable_tree'

      def load_data
        @taxonomies = Spree::Taxonomy.all
      end

      def scope
        load_data
      end

      def new
        @taxonomy = Spree::Taxonomy.new
        super
      end

      def collection
        return @collection if @collection.present?
        @collection = super
        @search = @collection.ransack(params[:q])
        @collection = @search.result
                             .page(params[:page])
                             .per(params[:per_page] || Spree::Backend::Config[:variants_per_page])
        @collection
      end

      def collection_url(options = {})
        transit_taxonomies_url(options)
      end

      def location_after_save
        if @object.previously_new_record?
          edit_transit_taxonomy_url(@object)
        else
          transit_taxonomies_url
        end
      end

      def model_class
        Spree::Taxonomy
      end

      def object_name
        'taxonomy'
      end
    end
  end
end
