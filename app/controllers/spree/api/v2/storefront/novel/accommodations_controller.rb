module Spree
  module Api
    module V2
      module Storefront
        module Novel
          class AccommodationsController < ::Spree::Api::V2::ResourceController
            private

            # override
            def collection
              @collection ||= SpreeCmCommissioner::Accommodations::Find.new(
                from_date: params[:from_date]&.to_date,
                to_date: params[:to_date]&.to_date,
                state_id: params[:state_id],
                number_of_adults: params[:number_of_adults].to_i,
                number_of_kids: params[:number_of_kids].to_i
              ).execute
            end

            # override
            def resource
              @resource ||= collection.find(params[:id])
            end

            # override
            def allowed_sort_attributes
              super << :min_price << :max_price
            end

            # override
            def resource_serializer
              Spree::V2::Storefront::AccommodationSerializer
            end

            # override
            def collection_serializer
              Spree::V2::Storefront::AccommodationSerializer
            end

            # override
            def required_schema
              SpreeCmCommissioner::AccommodationRequestSchema
            end
          end
        end
      end
    end
  end
end
