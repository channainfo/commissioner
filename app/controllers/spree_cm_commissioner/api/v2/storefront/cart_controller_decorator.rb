module SpreeCmCommissioner
  module Api
    module V2
      module Storefront
        module CartControllerDecorator
          def self.prepended(base)
            base.before_action :require_spree_current_user
            base.before_action :ensure_cart_exist, only: :add_item
          end

          # one usecase where this neccessary is when order.state is 'complete', but complated_at & payment_state is null,
          # this cause app to be stuck at book page because cart is not considered cart or completed.
          #
          # solution is to restart it back to cart.
          def restart_checkout_flow
            spree_authorize! :update, spree_current_order, order_token

            if spree_current_order.completed_at.present?
              render_error_payload('Cart already completed!')
            else
              spree_current_order.restart_checkout_flow
              spree_current_order.update_with_updater!

              render_serialized_payload { serialized_current_order }
            end
          end

          # we required only user can create cart
          # in case there is no cart, and user try to add item to cart,
          # it should create one instead of raising error.
          def ensure_cart_exist
            spree_authorize! :create, Spree::Order
            return if spree_current_order.present?

            create_cart_params = {
              user: spree_current_user,
              store: current_store,
              currency: current_currency,
              public_metadata: add_item_params[:public_metadata],
              private_metadata: add_item_params[:private_metadata]
            }

            @spree_current_order ||= create_service.call(create_cart_params).value
          end

          def set_quantity
            return render_error_item_quantity unless params[:quantity].to_i.positive?

            spree_authorize! :update, spree_current_order, order_token

            result = ::SpreeCmCommissioner::Cart::SetQuantity.call(
              order: spree_current_order,
              line_item: line_item,
              quantity: params[:quantity],
              guests_to_remove: params[:guests_to_remove]
            )

            render_order(result)
          end

          def add_item_params
            params.permit(:quantity, :variant_id, guests_to_remove: [], public_metadata: {}, private_metadata: {}, options: {})
          end
        end
      end
    end
  end
end

unless Spree::Api::V2::Storefront::CartController.ancestors.include?(SpreeCmCommissioner::Api::V2::Storefront::CartControllerDecorator)
  Spree::Api::V2::Storefront::CartController.prepend(SpreeCmCommissioner::Api::V2::Storefront::CartControllerDecorator)
end
