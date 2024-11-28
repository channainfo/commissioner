module Spree
  module Api
    module V2
      module Platform
        class PlacesController < ResourceController
          respond_to :json

          def index
            result = collection_serializer.new(collection).serializable_hash

            respond_with(result) do |format|
              format.json { render json: result }
            end
          end

          def collection
            @collection ||= fetch_places
          end

          def model_class
            SpreeCmCommissioner::Place
          end

          def resource_serializer
            SpreeCmCommissioner::Api::V2::Platform::PlaceSerializer
          end

          def collection_serializer
            SpreeCmCommissioner::Api::V2::Platform::PlaceSerializer
          end

          private

          def fetch_places
            filter = params[:filter] || {}
            name_filter = filter[:name_i_cont]

            new_places = SpreeCmCommissioner::GooglePlacesFetcher.call(name: name_filter)
            new_places.success? ? struct_places_with_id(new_places.google_places) : []
          end

          def struct_places_with_id(places)
            places.map do |place|
              place_struct = Struct.new(:id, :name, :base_64_content)
              place_struct.new(
                id: place.reference,
                name: place.name,
                base_64_content: Base64.strict_encode64(place.to_json)
              )
            end
          end
        end
      end
    end
  end
end
