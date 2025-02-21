module Spree
  module Api
    module V2
      module Tenant
        class CartController < BaseController
          include Spree::Api::V2::Storefront::OrderConcern
          include Spree::Api::V2::CouponCodesHelper
          include Spree::Api::V2::Storefront::MetadataControllerConcern

          around_action :wrap_with_multitenant_without, except: %i[create]

          before_action :ensure_valid_metadata, only: %i[create add_item]
          before_action :ensure_order, except: %i[create]
          before_action :load_variant, only: :add_item

          def show
            spree_authorize! :show, spree_current_order, order_token

            render_serialized_payload { serialized_current_order }
          end

          def create
            spree_authorize! :create, Spree::Order

            create_cart_params = {
              user: spree_current_user,
              store: current_store,
              currency: current_currency,
              public_metadata: add_item_params[:public_metadata],
              private_metadata: add_item_params[:private_metadata]
            }

            order = spree_current_order if spree_current_order.present?
            order ||= create_service.call(create_cart_params).value

            render_serialized_payload(201) { serialize_resource(order) }
          end

          def add_item
            spree_authorize! :update, spree_current_order, order_token
            spree_authorize! :show, @variant

            result = add_item_service.call(
              order: spree_current_order,
              variant: @variant,
              quantity: add_item_params[:quantity],
              public_metadata: add_item_params[:public_metadata],
              private_metadata: add_item_params[:private_metadata],
              options: add_item_params[:options]
            )

            render_order(result)
          end

          def destroy
            spree_authorize! :update, spree_current_order, order_token

            result = destroy_cart_service.call(order: spree_current_order)

            if result.success?
              head :no_content
            else
              render_error_payload(result.error)
            end
          end

          def set_quantity
            return render_error_item_quantity unless params[:quantity].to_i.positive?

            spree_authorize! :update, spree_current_order, order_token

            result = set_item_quantity_service.call(order: spree_current_order,
                                                    line_item: line_item,
                                                    quantity: params[:quantity]
                                                   )

            render_order(result)
          end

          private

          def wrap_with_multitenant_without(&block)
            MultiTenant.without(&block)
          end

          def resource_serializer
            Spree::Api::Dependencies.storefront_cart_serializer.constantize
          end

          def create_service
            Spree::Api::Dependencies.storefront_cart_create_service.constantize
          end

          def add_item_service
            Spree::Api::Dependencies.storefront_cart_add_item_service.constantize
          end

          def destroy_cart_service
            Spree::Api::Dependencies.storefront_cart_destroy_service.constantize
          end

          def set_item_quantity_service
            Spree::Api::Dependencies.storefront_cart_set_item_quantity_service.constantize
          end

          def line_item
            @line_item ||= spree_current_order.line_items.find(params[:line_item_id])
          end

          def load_variant
            @variant = current_store.variants.find(add_item_params[:variant_id])
          end

          def render_error_item_quantity
            render json: { error: I18n.t(:wrong_quantity, scope: 'spree.api.v2.cart') }, status: :unprocessable_entity
          end

          def serialize_estimated_shipping_rates(shipping_rates)
            estimate_shipping_rates_serializer.new(
              shipping_rates,
              params: serializer_params
            ).serializable_hash
          end

          def add_item_params
            params.permit(:quantity, :variant_id, public_metadata: {}, private_metadata: {}, options: {})
          end
        end
      end
    end
  end
end
