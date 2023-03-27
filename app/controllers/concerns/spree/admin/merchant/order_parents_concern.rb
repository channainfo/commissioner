module Spree
  module Admin
    module Merchant
      module OrderParentsConcern
        extend ActiveSupport::Concern

        included do
          before_action :load_customer
          before_action :load_subscription
        end

        protected

        # to be overridden
        def order; end

        def load_customer
          scope = current_vendor&.customers

          @customer ||= scope.find(params[:customer_id]) if params[:customer_id].present?
          @customer ||= order.customer if order.present?
        end

        def load_subscription
          scope = @customer&.subscriptions || current_vendor&.subscriptions

          @subscription ||= scope.find(params[:subscription_id]) if params[:subscription_id].present?
          @subscription ||= order.subscription if order.present?
        end
      end
    end
  end
end
