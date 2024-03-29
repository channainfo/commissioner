module Spree
  module Api
    module V2
      module Storefront
        class LineItemsController < ::Spree::Api::V2::ResourceController
          before_action :require_spree_current_user

          def collection
            spree_current_user.line_items.complete.paid.filter_by_event(params[:event])
          end

          def show
            line_item = Spree::LineItem.find(params[:id])
            render_serialized_payload { serialize_resource(line_item) }
          end

          def allowed_sort_attributes
            super << :to_date
            super << :from_date
          end

          def resource_serializer
            Spree::V2::Storefront::LineItemSerializer
          end

          def collection_serializer
            Spree::V2::Storefront::LineItemSerializer
          end
        end
      end
    end
  end
end
