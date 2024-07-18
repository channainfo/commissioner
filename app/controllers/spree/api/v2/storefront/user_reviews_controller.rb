module Spree
  module Api
    module V2
      module Storefront
        class UserReviewsController < Spree::Api::V2::ResourceController
          before_action :require_spree_current_user

          def collection
            product.taxon_star_ratings.where(star: params[:star]).all
          end

          def show
            product_id = params[:id]
            user_review = spree_current_user.reviews.find_by(product_id: product_id)
            render_serialized_payload { serialize_resource(user_review) }
          end

          def create
            user_review = product.reviews.create(review_params)
            if user_review.save
              render_serialized_payload(201) { serialize_resource(user_review) }
            else
              render_error_payload(user_review, 400)
            end
          end

          # override
          def resource_serializer
            SpreeCmCommissioner::V2::Storefront::ReviewSerializer
          end

          def collection_serializer
            SpreeCmCommissioner::V2::Storefront::TaxonStarRatingSerializer
          end

          private

          def product
            @product ||= Spree::Product.find(params[:product_id])
          end

          def review_params
            params.permit(:rating, :title, :review, :name, :show_identifier, :product_id,
                          taxon_reviews_attributes: %i[taxon_id rating]
            ).merge(user: spree_current_user)
          end
        end
      end
    end
  end
end
