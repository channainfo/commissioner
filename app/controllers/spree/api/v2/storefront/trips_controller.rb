module Spree
  module Api
    module V2
      module Storefront
        class TripsController < Spree::Api::V2::ResourceController
          def index
            render_serialized_payload do
              collection_serializer.new(collection).serializable_hash
            end
          end

          def show
            render_serialized_payload do
              object_serializer.new(resource).serializable_hash
            end
          end

          def finder_params
            {
              origin_id: params[:origin_id],
              destination_id: params[:destination_id],
              date: params[:date],
              vendor_id: params[:vendor_id]
            }
          end

          def model_class
            Spree::Variant
          end

          def collection
            @collection ||= collection_finder.new(options: finder_params).call
          end

          def resource
            @object ||= object_finder.new(trip_id: params[:id], date: params[:date]).call
          end

          def object_finder
            SpreeCmCommissioner::TripSeatLayoutQuery
          end

          def collection_finder
            SpreeCmCommissioner::TripSearchQuery
          end

          def object_serializer
            SpreeCmCommissioner::V2::Storefront::TripLayoutSerializer
          end

          def collection_serializer
            SpreeCmCommissioner::V2::Storefront::TripSerializer
          end
        end
      end
    end
  end
end
