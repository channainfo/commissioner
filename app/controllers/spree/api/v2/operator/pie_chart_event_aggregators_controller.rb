module Spree
  module Api
    module V2
      module Operator
        class PieChartEventAggregatorsController < ::Spree::Api::V2::ResourceController
          def resource
            @resource = pie_chart_event_aggregator_queries.call
          end

          def resource_serializer
            SpreeCmCommissioner::V2::Operator::PieChartEventAggregatorSerializer
          end

          private

          def pie_chart_event_aggregator_queries
            SpreeCmCommissioner::PieChartEventAggregatorQueries.new(
              taxon_id: params[:taxon_id],
              chart_type: params[:chart_type] || 'participation',
              refreshed: params[:refreshed] || false
            )
          end
        end
      end
    end
  end
end
