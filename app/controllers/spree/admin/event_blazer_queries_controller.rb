module Spree
  module Admin
    class EventBlazerQueriesController < Spree::Admin::ResourceController
      def model_class
        SpreeCmCommissioner::TaxonBlazerQuery
      end

      def object_name
        'spree_cm_commissioner_taxon_blazer_query'
      end

      def create
        event_blazer = SpreeCmCommissioner::TaxonBlazerQuery.new(taxon_id: params[:event_id], blazer_query_id: params[:blazer_query_id])
        if event_blazer.save
          flash[:success] = I18n.t('event_blazer_queries.success')
        else
          flash[:alert] = event_blazer.errors.full_messages.join(', ')
        end
        redirect_to blazer.query_path(id: event_blazer.blazer_query_id, event_id: event_blazer.taxon_id)
      end
    end
  end
end
