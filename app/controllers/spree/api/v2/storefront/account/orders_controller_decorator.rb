module Spree
  module Api
    module V2
      module Storefront
        module Account
          module OrdersControllerDecorator
            def collection
              if spree_current_user.present?
                if params[:request_state].present?
                  spree_current_user.orders.filter_by_request_state
                else
                  collection_finder.new(user: spree_current_user, store: current_store, state: params.delete(:state)).execute
                end
              else
                Spree::Order.where(token: params[:id])
              end
            end

            def resource
              resource = if spree_current_user.present?
                           resource_finder.new(user: spree_current_user, number: params[:id], store: current_store).execute.take
                         else
                           Spree::Order.find_by(token: params[:id])
                         end

              raise ActiveRecord::RecordNotFound if resource.nil?

              resource
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
