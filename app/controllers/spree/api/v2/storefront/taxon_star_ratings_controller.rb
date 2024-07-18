module Spree
  module Api
    module V2
      module Storefront
        class TaxonStarRatingsController < Spree::Api::V2::ResourceController
          def collection
            product.taxon_star_ratings.where(star: params[:star]).all
          end

          def collection_serializer
            SpreeCmCommissioner::V2::Storefront::TaxonStarRatingSerializer
          end

          private

          def product
            @product ||= Spree::Product.find(params[:product_id])
          end
        end
      end
    end
  end
end
