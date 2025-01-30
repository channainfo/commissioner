module Spree
  module Api
    module V2
      module Tenant
        class VendorsController < BaseController
          def index
            collection = scope.page(params[:page])
                              .per(params[:per_page])

            render_serialized_payload do
              serialize_collection(collection)
            end
          end

          def show
            resource = scope.find(params[:id])

            render_serialized_payload do
              serialize_resource(resource)
            end
          end

          def scope
            ::Spree::Vendor.active
          end

          def resource_serializer
            Spree::V2::Tenant::VendorSerializer
          end

          def collection_serializer
            Spree::V2::Tenant::VendorSerializer
          end
        end
      end
    end
  end
end
