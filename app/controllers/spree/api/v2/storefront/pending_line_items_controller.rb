module Spree
  module Api
    module V2
      module Storefront
        class PendingLineItemsController < ::Spree::Api::V2::ResourceController
          before_action :require_spree_current_user

          # override
          def collection_serializer
            Spree::V2::Storefront::LineItemSerializer
          end

          # override
          def resource_serializer
            Spree::V2::Storefront::LineItemSerializer
          end

          def collection
            Spree::LineItem.joins(:guests)
                           .where(order: spree_current_user.orders.complete, guests: { upload_later: true })
                           .distinct
                           .page(params[:page]).per(params[:per_page])
          end

          def index
            render_serialized_payload do
              serialize_collection(paginated_collection)
            end
          end

          def allowed_sort_attributes
            super << :to_date
            super << :from_date
          end
        end
      end
    end
  end
end
