module Spree
  module Admin
    class TaxonVendorsController < Spree::Admin::ResourceController
      belongs_to 'spree/taxonomy', optional: true, find_by: :permalink

      def index
        @taxon_vendors = @taxonomy.taxon_vendors
      end

      def model_class
        SpreeCmCommissioner::TaxonVendor
      end

      def object_name
        'spree_cm_commissioner_taxon_vendors'
      end

      def collection_url(options = {})
        admin_taxonomy_taxon_vendors_url(options)
      end
    end
  end
end
