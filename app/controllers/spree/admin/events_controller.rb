module Spree
  module Admin
    class EventsController < Spree::Admin::ResourceController
      before_action :load_taxonomy, only: [:index]

      def index
        params[:q] ||= {}
        @search = taxon_scope.ransack(params[:q])
        @taxons = fetch_taxons
        @taxons_for_dropdown = @taxonomy.taxons if @taxonomy
      end

      private

      def fetch_taxons
        scope = params[:taxon_id].present? ? filtered_taxons : searched_taxons
        scope.includes(:taxonomy).page(params[:page]).per(15)
      end

      def model_class
        Spree::Taxon
      end

      def load_taxonomy
        @taxonomy = Spree::Taxonomy.find_by(name: 'Events')
        return if @taxonomy

        flash[:error] = Spree.t('admin.events.taxonomy_not_found')
        redirect_to admin_events_path
      end

      def taxon_scope
        @taxonomy ? Spree::Taxon.where(kind: 2, depth: 1) : Spree::Taxon.none
      end

      def filtered_taxons
        taxon_scope.where(id: params[:taxon_id]).or(
          taxon_scope.where(parent_id: params[:taxon_id])
        ).distinct
      end

      def searched_taxons
        @search.result(distinct: true)
      end
    end
  end
end
