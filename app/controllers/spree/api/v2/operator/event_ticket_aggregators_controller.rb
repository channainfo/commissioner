module Spree
  module Api
    module V2
      module Operator
        class EventTicketAggregatorsController < ::Spree::Api::V2::ResourceController
          def resource
            @resource = SpreeCmCommissioner::EventTicketAggregatorQuery.new(
              taxon_id: params[:taxon_id],
              refreshed: params[:refreshed] || false
            ).call
          end

          def resource_serializer
            SpreeCmCommissioner::V2::Operator::EventTicketAggregatorSerializer
          end
        end
      end
    end
  end
end
