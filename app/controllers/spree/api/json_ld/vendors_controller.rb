module Spree
  module Api
    module JsonLd
      class VendorsController < ::Spree::Api::V2::Storefront::VendorsController
        def resource_serializer
          SpreeCmCommissioner::JsonLd::VendorSerializer
        end

        def collection_serializer
          SpreeCmCommissioner::JsonLd::VendorSerializer
        end

        def scope
          ::Spree::Vendor.active.includes(:image)
        end
      end
    end
  end
end
