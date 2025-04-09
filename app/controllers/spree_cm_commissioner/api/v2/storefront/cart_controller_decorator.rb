module SpreeCmCommissioner
  module Api
    module V2
      module Storefront
        module CartControllerDecorator
          def self.prepended(base)
            base.include SpreeCmCommissioner::OrderConcern
          end

          # Restart the checkout flow to bring the order back to the cart view
          def restart_checkout_flow
            spree_authorize! :update, spree_current_order, order_token

            spree_current_order.restart_checkout_flow
            spree_current_order.update_with_updater!

            render_serialized_payload { serialized_current_order }
          end
        end
      end
    end
  end
end

unless Spree::Api::V2::Storefront::CartController.ancestors.include?(SpreeCmCommissioner::Api::V2::Storefront::CartControllerDecorator)
  Spree::Api::V2::Storefront::CartController.prepend(SpreeCmCommissioner::Api::V2::Storefront::CartControllerDecorator)
end
