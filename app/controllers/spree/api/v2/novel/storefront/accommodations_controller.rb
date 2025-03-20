module Spree
  module Api
    module V2
      module Novel
        module Storefront
          class AccommodationsController < ::Spree::Api::V2::ResourceController
            private

            def collection
              @collection ||= collection_finder.call(params: params).value
            end

            def paginated_collection
              return @paginated_collection if defined?(@paginated_collection)

              @paginated_collection = super
              @paginated_collection = apply_service_availability(@paginated_collection)
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

            def allowed_sort_attributes
              super << :min_price << :max_price
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
              SpreeCmCommissioner::AccommodationUnitSearch
            end

            def resource_finder
              SpreeCmCommissioner::AccommodationUnitSearch
            end

            def required_schema
              SpreeCmCommissioner::AccommodationRequestSchema
            end
          end
        end
      end
    end
  end
end
