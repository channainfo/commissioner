module Spree
  module Api
    module V2
      module Organizer
        class TicketsController < ::Spree::Api::V2::Organizer::BaseController
          def index
            event = Spree::Taxon.find(params[:event_id])

            resource = event.products.page(params[:page]).per(params[:per_page])

            render_serialized_payload do
              collection_serializer.new(
                resource,
                collection_options(resource)
              ).serializable_hash
            end
          end

          def show
            resource = Spree::Product.find(params[:id])

            render_serialized_payload do
              Spree::V2::Organizer::TicketSerializer.new(resource).serializable_hash
            end
          end

          def collection_serializer
            ::Spree::V2::Organizer::TicketSerializer
          end
        end
      end
    end
  end
end
