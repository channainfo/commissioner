module Spree
  module Admin
    class TaxonChildrensController < Spree::Admin::ResourceController
      before_action :load_taxonomy_taxon, only: [:index]

      def index; end

      private

      def model_class
        Spree::Taxon
      end

      def load_taxonomy_taxon
        @taxonomy = Spree::Taxonomy.find(params[:taxonomy_id])
        @taxon = @taxonomy.taxons.find(params[:taxon_id])
      end
    end
  end
end
