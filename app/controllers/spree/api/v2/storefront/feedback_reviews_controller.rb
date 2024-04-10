module Spree
  module Api
    module V2
      module Storefront
        class FeedbackReviewsController < Spree::Api::V2::ResourceController
          before_action :load_review

          def create
            feedback_review = @review.feedback_reviews.create(feedback_review_params)

            if feedback_review.save
              render_serialized_payload(201) { serialize_resource(feedback_review) }
            else
              render_error_payload(review, 400)
            end
          end

          # override
          def resource_serializer
            SpreeCmCommissioner::V2::Storefront::FeedbackReviewSerializer
          end

          private

          def load_review
            @review ||= Spree::Review.find(params[:review_id])
          end

          def feedback_review_params
            params.permit(:rating, :comment).merge(user: spree_current_user)
          end
        end
      end
    end
  end
end
