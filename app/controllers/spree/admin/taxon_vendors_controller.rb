module Spree
  module Admin
    class TaxonVendorsController < Spree::Admin::ResourceController
      before_action :load_taxonomy_taxon, except: [:index]

      def index
        @taxonomy = Spree::Taxonomy.find(params[:taxonomy_id])
        @taxon = @taxonomy.taxons.find(params[:taxon_id])

        # Retrieve taxon vendors associated with the taxon, including the vendor association
        @taxon_vendors = @taxon.taxon_vendors.includes(:vendor)
      end

      private

      def load_taxonomy_taxon
        @taxonomy = Spree::Taxonomy.find(params[:taxonomy_id])
        @taxon = @taxonomy.taxons.find(params[:taxon_id])
        @taxon_vendors = @taxon.taxon_vendors
      end

      def model_class
        SpreeCmCommissioner::TaxonVendor
      end

      def object_name
        'spree_cm_commissioner_taxon_vendor'
      end

      def collection_url(options = {})
        admin_taxonomy_taxon_taxon_vendors_url(taxonomy: @taxonomy, taxon: @taxon, options: options)
      end
    end
  end
end
