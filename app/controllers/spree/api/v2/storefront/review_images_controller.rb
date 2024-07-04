module Spree
  module Api
    module V2
      module Storefront
        class ReviewImagesController < Spree::Api::V2::ResourceController
          def create
            context = SpreeCmCommissioner::ReviewImageCreator.call(
              review: review,
              url: params[:url]
            )
            if context.success?
              render_serialized_payload { serialize_resource(context.result) }
            else
              render_error_payload(context.message)
            end
          end

          private

          def review
            @review ||= Spree::Review.find(params[:user_review_id])
          end

          def resource_serializer
            Spree::V2::Storefront::ReviewImageSerializer
          end
        end
      end
    end
  end
end
