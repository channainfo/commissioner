module Spree
  module Api
    module V2
      module Organizer
        class EventsController < ::Spree::Api::V2::Organizer::BaseController
          def index
            collection = Spree::Taxon.where(vendor_id: params[:vendor_id])
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
            resource = Spree::Taxon.find(params[:id])
            render_serialized_payload { serialize_resource(resource) }
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
        end
      end
    end
  end
end
