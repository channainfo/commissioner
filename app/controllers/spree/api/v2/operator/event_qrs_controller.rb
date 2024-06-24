module Spree
  module Api
    module V2
      module Operator
        class EventQrsController < ::Spree::Api::V2::ResourceController
          before_action :require_spree_current_user
          before_action :load_event, only: [:show]

          def show
            context = SpreeCmCommissioner::EventQrGenerator.call(
              operator: spree_current_user,
              event: @event,
              expired_in_mn: params[:expired_in_mn]&.to_i || 5
            )

            render_serialized_payload { serialize_resource(context.event_qr) }
          end

          private

          def load_event
            @event = Spree::Taxon.find(params[:id])
          end

          # override
          def collection_serializer
            SpreeCmCommissioner::V2::Operator::EventQrSerializer
          end

          # override
          def resource_serializer
            SpreeCmCommissioner::V2::Operator::EventQrSerializer
          end
        end
      end
    end
  end
end
