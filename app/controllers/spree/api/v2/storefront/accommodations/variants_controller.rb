module Spree
  module Api
    module V2
      module Storefront
        class Accommodations::VariantsController < ::Spree::Api::V2::ResourceController
          private

          # override
          def collection
            @collection ||= SpreeCmCommissioner::Accommodations::FindVariant.new(
              from_date: params[:from_date]&.to_date,
              to_date: params[:to_date]&.to_date,
              vendor_id: params[:accommodation_id],
              number_of_adults: params[:number_of_adults].to_i,
              number_of_kids: params[:number_of_kids].to_i
            ).execute
          end

          # override
          def resource
            @resource ||= collection.find(params[:id])
          end

          # override
          def resource_serializer
            Spree::V2::Storefront::VariantSerializer
          end

          # override
          def collection_serializer
            Spree::V2::Storefront::VariantSerializer
          end

          # override
          def required_schema
            SpreeCmCommissioner::VariantRequestSchema
          end
        end
      end
    end
  end
end
