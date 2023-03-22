module Spree
  module Admin
    module Merchant
      class OrdersController < Spree::Admin::Merchant::BaseController
        before_action :load_parents
        before_action :load_order, if: -> { member_action? }

        def collection
          return @collection if defined?(@collection)

          @search = subscription.orders.ransack(params[:q])
          @collection = @search.result.page(page).per(per_page)
        end

        def load_parents
          subscription
          customer
        end

        def load_order
          @orders = @object
        end

        def subscription
          @subscription = SpreeCmCommissioner::Subscription.find_by(id: params[:subscription_id])
        end

        def customer
          @customer = SpreeCmCommissioner::Customer.find_by(id: params[:customer_id])
        end

        # @overrided
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
