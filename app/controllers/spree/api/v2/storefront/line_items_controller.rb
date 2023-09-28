module Spree
  module Api
    module V2
      module Storefront
        class LineItemsController < ::Spree::Api::V2::ResourceController
          before_action :require_spree_current_user

          def collection
            spree_current_user.line_items.filter_by_event(params[:event])
          end

          def allowed_sort_attributes
            super << :to_date
            super << :from_date
          end

          def collection_serializer
            Spree::V2::Storefront::LineItemSerializer
          end
        end
      end
    end
  end
end
