module Spree
  module Api
    module V2
      module Storefront
        class NearbyPlacesController < ::Spree::Api::V2::ResourceController
          before_action :load_vendor

          private

          def collection
            @collection ||= @vendor.nearby_places
          end

          def load_vendor
            @vendor ||= Spree::Vendor.find_by(slug: params[:vendor_id])
          end

          def model_class
            SpreeCmCommissioner::VendorPlace
          end

          def collection_serializer
            Spree::V2::Storefront::NearbyPlaceSerializer
          end
        end
      end
    end
  end
end