module Spree
  module Admin
    class UserTaxonsController < Spree::Admin::ResourceController
      before_action :load_parents

      def index
        # Retrieve user taxons associated with the taxon
        @user_taxons = @taxon.user_events
      end

      private

      def load_parents
        @taxonomy = Spree::Taxonomy.find(params[:taxonomy_id])
        @taxon = @taxonomy.taxons.find(params[:taxon_id])
      end

      def model_class
        SpreeCmCommissioner::UserEvent
      end

      def object_name
        'spree_cm_commissioner_user_event'
      end

      def collection_url(options = {})
        admin_taxonomy_taxon_user_taxons_url(taxonomy: @taxonomy, taxon: @taxon, options: options)
      end
    end
  end
end
