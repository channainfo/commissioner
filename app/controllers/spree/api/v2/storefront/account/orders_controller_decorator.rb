module Spree
  module Api
    module V2
      module Storefront
        module Account
          module OrdersControllerDecorator
            def collection
              collection_finder.new(user: spree_current_user, store: current_store, state: params.delete(:state)).execute
            end

            def collection_finder
              SpreeCmCommissioner::Orders::FindByState
            end
          end
        end
      end
    end
  end
end

Spree::Api::V2::Storefront::Account::OrdersController.prepend(Spree::Api::V2::Storefront::Account::OrdersControllerDecorator)
