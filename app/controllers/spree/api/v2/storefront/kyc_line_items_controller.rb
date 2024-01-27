module Spree
  module Api
    module V2
      module Storefront
        class KycLineItemsController < Spree::Api::V2::ResourceController
          include OrderConcern

          before_action :ensure_order

          # override
          def model_class
            Spree::LineItem
          end

          # override
          def resource_serializer
            SpreeCmCommissioner::V2::Storefront::KycLineItemSerializer
          end

          # override
          def index
            guest_line_items = spree_current_order.line_items

            render_serialized_payload { serialize_resource(guest_line_items) }
          end

          # override
          def show
            guest_line_item = spree_current_order.line_items.find(params['id'])

            render_serialized_payload { serialize_resource(guest_line_item) }
          end
        end
      end
    end
  end
end
