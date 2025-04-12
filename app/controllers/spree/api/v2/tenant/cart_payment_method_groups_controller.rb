module Spree
  module Api
    module V2
      module Tenant
        class CartPaymentMethodGroupsController < BaseController
          around_action :wrap_with_multitenant_without
          include Spree::Api::V2::Storefront::OrderConcern

          before_action :ensure_order

          # override
          def index
            render_serialized_payload do
              collection_serializer.new(collection, { include: resource_includes }).serializable_hash
            end
          end

          # override
          def collection
            @collection ||= SpreeCmCommissioner::PaymentMethods::GroupByBank.new.execute(
              payment_methods: spree_current_order.available_payment_methods,
              preferred_payment_method_id: spree_current_user&.preferred_payment_method_id
            )
          end

          # override
          def collection_serializer
            Spree::V2::Tenant::PaymentMethodGroupSerializer
          end

          private

          def wrap_with_multitenant_without(&block)
            MultiTenant.without(&block)
          end
        end
      end
    end
  end
end
