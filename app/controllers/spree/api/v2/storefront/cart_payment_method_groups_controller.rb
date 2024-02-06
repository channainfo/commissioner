module Spree
  module Api
    module V2
      module Storefront
        class CartPaymentMethodGroupsController < Spree::Api::V2::ResourceController
          include OrderConcern

          before_action :require_spree_current_user
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
              preferred_payment_method_id: spree_current_user.preferred_payment_method_id
            )
          end

          # override
          def collection_serializer
            SpreeCmCommissioner::V2::Storefront::PaymentMethodGroupSerializer
          end
        end
      end
    end
  end
end
