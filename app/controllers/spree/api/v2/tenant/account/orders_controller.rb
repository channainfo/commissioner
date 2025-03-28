module Spree
  module Api
    module V2
      module Tenant
        module Account
          class OrdersController < BaseController
            around_action :wrap_with_multitenant_without
            before_action :require_spree_current_user

            def collection
              scope
            end

            def resource
              @resource ||= scope.find_by!(number: params[:id])
            end

            private

            def wrap_with_multitenant_without(&block)
              MultiTenant.without(&block)
            end

            def allowed_sort_attributes
              super << :completed_at
            end

            def scope
              spree_current_user.orders.complete
            end

            def collection_serializer
              Spree::V2::Tenant::OrderSerializer
            end

            def resource_serializer
              Spree::V2::Tenant::OrderSerializer
            end

            def model_class
              Spree::Order
            end
          end
        end
      end
    end
  end
end
