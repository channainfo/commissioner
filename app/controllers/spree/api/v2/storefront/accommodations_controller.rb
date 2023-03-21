module Spree
  module Api
    module V2
      module Storefront
        class AccommodationsController < ::Spree::Api::V2::ResourceController
          private

          def collection
            @collection ||= collection_finder.call(params: params).value
          end

          def paginated_collection
            @paginated_collection ||= apply_service_availability(collection)
          end

          def resource
            resource = resource_finder.call(params: params).value
            raise ActiveRecord::RecordNotFound if resource.nil?

            apply_service_availability(resource)
          end

          def apply_service_availability(resource)
            SpreeCmCommissioner::ApplyServiceAvailability.call(calendarable: resource,
                                                               from_date: params[:from_date].to_date,
                                                               to_date: params[:to_date].to_date
                                                              ).value
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
