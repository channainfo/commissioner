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
            @paginated_collection ||= apply_extras(collection)
          end

          def resource
            resource = resource_finder.call(params: params).value
            raise ActiveRecord::RecordNotFound if resource.nil?

            apply_extras(resource)
          end

          def apply_extras(resource)
            resource = apply_service_availability(resource)
            apply_promotions(resource)
          end

          def apply_service_availability(resource)
            SpreeCmCommissioner::ApplyServiceAvailability.call(
              calendarable: resource,
              from_date: params[:from_date].to_date,
              to_date: params[:to_date].to_date
            ).value
          end

          def apply_promotions(resource)
            SpreeCmCommissioner::ApplyVendorPromotions.call(
              vendors: resource.respond_to?(:each) ? resource : [resource],
              user: spree_current_user,
              from_date: params[:from_date].to_date,
              to_date: params[:to_date].to_date
            ).vendors
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

          def required_schema
            SpreeCmCommissioner::AccommodationRequestSchema
          end
        end
      end
    end
  end
end
