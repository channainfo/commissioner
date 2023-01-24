module Spree
  module Api
    module V2
      module Storefront
        class AccommodationsController < ::Spree::Api::V2::ResourceController

          def index
            render_serialized_payload do
              serialize_collection(paginated_collection)
            end
          end

          def show
            render_result(resource)
          end

          private

          def collection
            @collection ||= SpreeCmCommissioner::AccommodationSearch.call(params: params).value
          end

          def resource
            @resource ||= SpreeCmCommissioner::AccommodationDetail.call(params: params)
          end

          def model_class
            Spree::Vendor
          end

          def resource_serializer
            Spree::V2::Storefront::AccommodationSerializer
          end

          def collection_serializer
            resource_serializer
          end
        end
      end
    end
  end
end