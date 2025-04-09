module Spree
  module Api
    module V2
      module Tenant
        class CheckoutController < BaseController
          include Spree::Api::V2::Storefront::OrderConcern

          around_action :wrap_with_multitenant_without

          before_action :ensure_order

          def next
            spree_authorize! :update, spree_current_order, order_token

            result = next_service.call(order: spree_current_order)

            render_order(result)
          end

          def advance
            spree_authorize! :update, spree_current_order, order_token

            result = advance_service.call(order: spree_current_order)

            render_order(result)
          end

          def complete
            spree_authorize! :update, spree_current_order, order_token

            result = complete_service.call(order: spree_current_order)

            render_order(result)
          end

          def update
            spree_authorize! :update, spree_current_order, order_token

            result = update_service.call(
              order: spree_current_order,
              params: params,
              # defined in https://github.com/spree/spree/blob/master/core/lib/spree/core/controller_helpers/strong_parameters.rb#L19
              permitted_attributes: permitted_checkout_attributes,
              request_env: request.headers.env
            )

            render_order(result)
          end

          def create_payment
            result = create_payment_service.call(order: spree_current_order, params: params)

            if result.success?
              render_serialized_payload(201) { serialize_resource(spree_current_order.reload) }
            else
              render_error_payload(result.error)
            end
          end

          private

          def wrap_with_multitenant_without(&block)
            MultiTenant.without(&block)
          end

          def resource_serializer
            Spree::Api::Dependencies.storefront_cart_serializer.constantize
          end

          def next_service
            Spree::Api::Dependencies.storefront_checkout_next_service.constantize
          end

          def advance_service
            Spree::Api::Dependencies.storefront_checkout_advance_service.constantize
          end

          def complete_service
            Spree::Api::Dependencies.storefront_checkout_complete_service.constantize
          end

          def update_service
            Spree::Api::Dependencies.storefront_checkout_update_service.constantize
          end

          def create_payment_service
            Vpago::Payments::FindOrCreate
          end
        end
      end
    end
  end
end
