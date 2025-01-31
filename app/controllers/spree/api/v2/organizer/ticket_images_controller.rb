module Spree
  module Api
    module V2
      module Organizer
        class TicketImagesController < ::Spree::Api::V2::Organizer::BaseController
          before_action :load_ticket

          def index
            images = @ticket.images

            render_serialized_payload do
              collection_serializer.new(images).serializable_hash
            end
          end

          def collection_serializer
            ::Spree::V2::Organizer::ImageSerializer
          end

          def load_ticket
            @ticket ||= Spree::Product.find(params[:ticket_id])
          end
        end
      end
    end
  end
end
