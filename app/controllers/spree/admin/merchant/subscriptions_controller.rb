module Spree
  module Admin
    module Merchant
      class SubscriptionsController < Spree::Admin::Merchant::BaseController
        before_action :load_customer

        protected

        def collection
          return @collection if defined?(@collection)

          @search = customer.subscriptions.ransack(params[:q])
          @collection = @search.result.page(page).per(per_page)
        end

        def load_customer
          customer
        end

        def customer
          @customer ||= SpreeCmCommissioner::Customer.find(params[:customer_id])
        end

        # @overrided
        def model_class
          SpreeCmCommissioner::Subscription
        end

        # @overrided
        def object_name
          'spree_cm_commissioner_subscription'
        end

        # @overrided
        def collection_url(options = {})
          admin_merchant_customer_subscriptions_url(options)
        end
      end
    end
  end
end
