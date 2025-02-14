module Spree
  module Api
    module V2
      module Tenant
        class CartGuestsController < CartController
          around_action :wrap_with_multitenant_without

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

          private

          def wrap_with_multitenant_without(&block)
            MultiTenant.without(&block)
          end
        end
      end
    end
  end
end
