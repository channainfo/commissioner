module Spree
  module Api
    module V2
      module Operator
        class EventQrsController < ::Spree::Api::V2::ResourceController
          include ActionController::MimeResponds

          before_action :require_spree_current_user
          before_action :load_event, only: [:show]

          def show
            qr_resource = @event.jwt_token(spree_current_user)
            render_serialized_payload { serialize_resource(qr_resource) }
          end

          private

          def load_event
            @event = Spree::Taxon.find_by(id: params[:id])
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
