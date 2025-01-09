module Spree
  module Api
    module V2
      module Organizer
        class EventsController < ::Spree::Api::V2::Organizer::BaseController
          def index
            collection = model_class.where(vendor_id: params[:vendor_id])
                                     .page(params[:page])
                                     .per(params[:per_page])
            render_serialized_payload do
              serialize_collection.new(
                collection,
                collection_options(collection)
              ).serializable_hash
            end
          end

          def show
            resource = model_class.find(params[:id])
            render_serialized_payload { serialize_resource(resource) }
          end

          def create
            taxonomy = Spree::Taxonomy.find(5)
            
            resource = model_class.new(
              event_params.merge(
                parent_id: taxonomy.root.id
              )
            )

            if resource.save
              render_serialized_payload(201) { serialize_resource(resource) }
            else
              render_error_payload(resource.errors.full_messages.to_sentence, 400)
            end
          end

          def update
            resource = model_class.find(params[:id])
            if resource.update(event_params)
              render_serialized_payload { serialize_resource(resource) }
            else
              render_error_payload(resource.errors.full_messages.to_sentence, 400)
            end
          end

          def destroy
            resource = model_class.find(params[:id])
            if resource.destroy
              render_serialized_payload { serialize_resource(resource) }
            else
              render_error_payload(resource.errors.full_messages.to_sentence, 400)
            end
          end

          def model_class
            Spree::Taxon
          end

          def serialize_resource(resource)
            Spree::V2::Organizer::EventSerializer.new(
              resource,
              include: resource_includes
            ).serializable_hash
          end

          def serialize_collection
            ::Spree::V2::Organizer::EventSerializer
          end

          private

          def event_params
            params.permit(
              :name,
              :subtitle,
              :from_date,
              :to_date,
              :vendor_id,
              :description
            )
          end
        end
      end
    end
  end
end
