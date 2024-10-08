module Spree
  module Api
    module V2
      module Storefront
        class VendorPhotosController < Spree::Api::V2::ResourceController
          def collection
            vendor.photos
          end

          private

          def vendor
            @vendor ||= Spree::Vendor.find(params[:vendor_id])
          end

          def collection_serializer
            SpreeCmCommissioner::V2::Storefront::AssetSerializer
          end
        end
      end
    end
  end
end
