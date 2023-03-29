module Spree
  module Admin
    module Merchant
      class OrdersController < Spree::Admin::Merchant::BaseController
        include Spree::Admin::OrderConcern
        include Spree::Admin::Merchant::OrderParentsConcern

        protected

        def scope
          @subscription&.orders || @customer&.orders || current_vendor&.subscription_orders
        end

        # @overrided

        # override order method with @order
        attr_reader :order

        def collection
          return @collection if defined?(@collection)

          load_customer
          load_subscription

          @search = scope.ransack(params[:q])
          @collection = @search.result.page(page).per(per_page)
        end

        def load_resource_instance
          return scope.new if new_actions.include?(action)

          scope.find_by!(number: params[:id])
        end

        def model_class
          Spree::Order
        end

        def object_name
          'order'
        end
      end
    end
  end
end
