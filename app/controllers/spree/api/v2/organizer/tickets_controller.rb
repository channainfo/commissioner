module Spree
  module Api
    module V2
      module Organizer
        class TicketsController < ::Spree::Api::V2::Organizer::BaseController
          before_action :load_store, only: %i[create]
          before_action :load_event, only: %i[create]

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

          def create
            resource = Spree::Product.new(product_params)
            resource.stores << @store
            resource.taxons << @event

            if resource.save
              render_serialized_payload(201) { serialize_resource(resource) }
            else
              render_error_payload(resource.errors.full_messages.to_sentence, 400)
            end
          end

          def update
            resource = Spree::Product.find(params[:id])

            if resource.update(product_params)
              render_serialized_payload { serialize_resource(resource) }
            else
              render_error_payload(resource.errors.full_messages.to_sentence, 400)
            end
          end

          def destroy
            resource = Spree::Product.find(params[:id])

            if resource.destroy
              render_serialized_payload { serialize_resource(resource) }
            else
              render_error_payload(resource.errors.full_messages.to_sentence, 400)
            end
          end

          private

          def load_store
            @store ||= Spree::Store.first
          end

          def load_event
            @event ||= Spree::Taxon.find_by(id: params[:event_id])
          end

          def collection_serializer
            ::Spree::V2::Organizer::TicketSerializer
          end

          def resource_serializer
            ::Spree::V2::Organizer::TicketSerializer
          end

          def product_params
            params.permit(
              :name,
              :price,
              :compare_at_price,
              :available_on,
              :kyc,
              :description,
              :shipping_category_id,
              :product_type,
              :status
            )
          end
        end
      end
    end
  end
end
