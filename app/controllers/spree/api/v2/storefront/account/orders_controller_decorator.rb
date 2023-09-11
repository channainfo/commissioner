module Spree
  module Api
    module V2
      module Storefront
        module Account
          module OrdersControllerDecorator
            def collection
              if params[:request_state].present?
                spree_current_user.orders.filter_by_request_state
              elsif params[:event].present?
                spree_current_user.orders.filter_by_event(event: params[:event])
              else
                collection_finder.new(user: spree_current_user, store: current_store, state: params.delete(:state)).execute
              end
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
