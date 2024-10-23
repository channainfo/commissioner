module Spree
  module Api
    module V2
      module Storefront
        class LineItemsController < ::Spree::Api::V2::ResourceController
          def collection
            if spree_current_user.nil?
              line_items_by_order_tokens
            else
              spree_current_user.line_items.complete.paid.filter_by_event(params[:event])
            end
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

          def line_items_by_order_tokens
            order_tokens = params[:order_tokens]
            event = params[:event]

            return Spree::LineItem.none if order_tokens.blank?

            Spree::LineItem.joins(:order)
                           .where(spree_orders: { token: order_tokens, state: 'complete', user_id: nil })
                           .filter_by_event(event)
                           .page(params[:page])
                           .per(params[:per_page])
          end
        end
      end
    end
  end
end
