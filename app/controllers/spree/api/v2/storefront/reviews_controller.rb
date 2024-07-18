module Spree
  module Api
    module V2
      module Storefront
        class ReviewsController < Spree::Api::V2::ResourceController
          def collection
            vendor.reviews.approved
                  .where(params[:rating].present? ? { rating: params[:rating] } : {})
                  .page(params[:page])
                  .per(params[:per_page])
          end

          def show
            review = Spree::Review.find(params[:id])
            render_serialized_payload { serialize_resource(review) }
          end

          # override
          def resource_serializer
            SpreeCmCommissioner::V2::Storefront::ReviewSerializer
          end

          def collection_serializer
            SpreeCmCommissioner::V2::Storefront::ReviewSerializer
          end

          private

          def vendor
            @vendor ||= Spree::Vendor.find(params[:vendor_id])
          end
        end
      end
    end
  end
end
