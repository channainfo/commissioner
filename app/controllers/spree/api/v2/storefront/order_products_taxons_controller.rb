module Spree
  module Api
    module V2
      module Storefront
        class OrderProductsTaxonsController < ::Spree::Api::V2::ResourceController
          def collection
            @collection || order.taxons
          end

          def order
            Spree::Order.find(order_params[:id])
          end

          def collection_serializer
            Spree::V2::Storefront::TaxonSerializer
          end

          def order_params
            params.permit(:id)
          end
        end
      end
    end
  end
end
