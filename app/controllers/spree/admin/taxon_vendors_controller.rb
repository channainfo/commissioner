module Spree
  module Admin
    class TaxonVendorsController < Spree::Admin::ResourceController
      def index
        @taxonomy = Spree::Taxonomy.find(params[:taxonomy_id])
        @taxon = @taxonomy.taxons.find(params[:taxon_id])

        # Retrieve taxon vendors associated with the taxon
        @taxon_vendors = @taxon.taxon_vendors
      end

      def model_class
        SpreeCmCommissioner::TaxonVendor
      end

      def object_name
        'spree_cm_commissioner_taxon_vendor'
      end

      def collection_url(options = {})
        admin_taxonomy_taxon_taxon_vendors_url(taxonomy_id: @taxonomy, taxon_id: @taxon, options: options)
      end
    end
  end
end
