module Spree
  module Api
    module V2
      module Storefront
        module Account
          module OrdersControllerDecorator
            def collection
              collection_finder.new(user: spree_current_user, store: current_store, state: params.delete(:state)).execute
            end

            def resource
              resource = resource_finder.new(user: spree_current_user, number: params[:id], store: current_store,
                                             state: params.delete(:state)
              ).execute.take
              raise ActiveRecord::RecordNotFound if resource.nil?

              resource
            end

            def collection_finder
              Spree::Orders::FindByState
            end

            def resource_finder
              Spree::Orders::FindByState
            end
          end
        end
      end
    end
  end
end

Spree::Api::V2::Storefront::Account::OrdersController.prepend(Spree::Api::V2::Storefront::Account::OrdersControllerDecorator)
