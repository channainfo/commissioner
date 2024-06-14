module Spree
  module Api
    module V2
      module Operator
        class TaxonsController < ::Spree::Api::V2::ResourceController
          before_action :require_spree_current_user
          before_action :load_event, only: [:show]

          def show
            render_serialized_payload { serialize_resource(@event) }
          end

          # override
          def collection_serializer
            SpreeCmCommissioner::V2::Operator::TaxonSerializer
          end

          # override
          def resource_serializer
            SpreeCmCommissioner::V2::Operator::TaxonSerializer
          end

          def load_event
            @event = Spree::Taxon.find_by(id: params[:id])
          end
        end
      end
    end
  end
end
