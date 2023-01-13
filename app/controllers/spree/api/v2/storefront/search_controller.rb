module Spree
  module Api
    module V2
      module Storefront
        class SearchController < ::Spree::Api::V2::ResourceController

          def index
            render_serialized_payload do
              serialize_collection(paginated_collection)
            end
          end

          private

          def collection
            ## TODO: handle only less than 1 month
            passenger_options = SpreeCmCommissioner::PassengerOption.new()
            @collection ||= SpreeCmCommissioner::VendorSearch.call(params: params, passenger_options: passenger_options)
          end

          def model_class
            Spree::Vendor
          end

          def collection_serializer
            Spree::V2::Storefront::VendorSerializer
          end

          def serialize_collection(collection)
            collection_serializer.new(
              collection,
              collection_options(collection).merge(is_collection: true)
            ).serializable_hash
          end
        end
      end
    end
  end
end