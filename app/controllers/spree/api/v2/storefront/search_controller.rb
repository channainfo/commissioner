module Spree
  module Api
    module V2
      module Storefront
        class SearchController < ::Spree::Api::V2::ResourceController

          private

          def collection
            @collection ||= province_id.present? ? scope.ransack(option_values_presentation_eq: province_id).result(distinct: true) : scope
          end

          def province_id
            params[:province_id]
          end

          def scope
            model_class.active
          end

          def model_class
            ::Spree::Vendor
          end

          def collection_serializer
            Spree::V2::Storefront::VendorSerializer
          end
        end
      end
    end
  end
end