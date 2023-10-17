module SpreeCmCommissioner
  module Api
    module V2
      module Storefront
        module CartControllerDecorator
          def self.prepended(base)
            base.before_action :require_spree_current_user
            base.before_action :ensure_cart_exist, only: :add_item
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
        end
      end
    end
  end
end

unless Spree::Api::V2::Storefront::CartController.ancestors.include?(SpreeCmCommissioner::Api::V2::Storefront::CartControllerDecorator)
  Spree::Api::V2::Storefront::CartController.prepend(SpreeCmCommissioner::Api::V2::Storefront::CartControllerDecorator)
end
