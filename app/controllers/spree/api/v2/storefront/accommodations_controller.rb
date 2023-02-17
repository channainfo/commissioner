module Spree
  module Api
    module V2
      module Storefront
        class AccommodationsController < ::Spree::Api::V2::ResourceController
          private

          def collection
            collection_finder.call(params: params).value
          end

          def resource
            resource = resource_finder.call(params: params).value
            raise ActiveRecord::RecordNotFound if resource.nil?

            resource
          end

          def model_class
            Spree::Vendor
          end

          def resource_serializer
            Spree::V2::Storefront::AccommodationSerializer
          end

          def collection_serializer
            Spree::V2::Storefront::AccommodationSerializer
          end

          def collection_finder
            SpreeCmCommissioner::AccommodationSearchDetail
          end

          def resource_finder
            SpreeCmCommissioner::AccommodationSearchDetail
          end
        end
      end
    end
  end
end
