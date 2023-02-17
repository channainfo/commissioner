module Spree
  module Api
    module V2
      module Storefront
        class ProvincesController < ::Spree::Api::V2::ResourceController
          def collection
            Spree::State.where('total_inventory > ?', 0)
          end

          def collection_serializer
            Spree::V2::Storefront::StateSerializer
          end
        end
      end
    end
  end
end
