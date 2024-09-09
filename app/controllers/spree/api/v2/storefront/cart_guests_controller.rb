module Spree
  module Api
    module V2
      module Storefront
        class CartGuestsController < Spree::Api::V2::Storefront::CartController
          # :line_item_id
          def create
            spree_authorize! :update, spree_current_order, order_token

            result = SpreeCmCommissioner::Cart::AddGuest.call(
              order: spree_current_order,
              line_item: line_item
            )

            render_order(result)
          end

          # :line_item_id, :guest_id
          def destroy
            spree_authorize! :update, spree_current_order, order_token

            result = SpreeCmCommissioner::Cart::RemoveGuest.call(
              order: spree_current_order,
              line_item: line_item,
              guest_id: params[:guest_id]
            )

            render_order(result)
          end
        end
      end
    end
  end
end
