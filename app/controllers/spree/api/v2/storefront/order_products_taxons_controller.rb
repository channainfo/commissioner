module Spree
  module Api
    module V2
      module Storefront
        class OrderProductsTaxonsController < ::Spree::Api::V2::ResourceController
          def collection
            @collection || order.taxons
          end

          def order
            @order ||= Spree::Order.find_by!(number: order_params[:number])
          end

          def collection_serializer
            Spree::V2::Storefront::TaxonSerializer
          end

          def order_params
            params.permit(:number)
          end
        end
      end
    end
  end
end
