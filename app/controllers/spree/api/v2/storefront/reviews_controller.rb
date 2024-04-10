module Spree
  module Api
    module V2
      module Storefront
        class ReviewsController < Spree::Api::V2::ResourceController
          before_action :load_product, only: %i[index create]

          def collection
            @product.reviews.approved
          end

          def create
            review = @product.reviews.create(review_params)

            if review.save
              render_serialized_payload(201) { serialize_resource(review) }
            else
              render_error_payload(review, 400)
            end
          end

          # override
          def resource_serializer
            SpreeCmCommissioner::V2::Storefront::ReviewSerializer
          end

          def collection_serializer
            SpreeCmCommissioner::V2::Storefront::ReviewSerializer
          end

          private

          def load_product
            @product ||= Spree::Product.find(params[:product_id])
          end

          def review_params
            params.permit(:rating, :title, :review, :name, :show_identifier).merge(user: spree_current_user)
          end
        end
      end
    end
  end
end
