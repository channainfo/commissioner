# app/controllers/spree/api/v2/inventory_controller.rb
module Spree
  module Api
    module V2
      module Storefront
        class InventoryController < ::Spree::Api::V2::ResourceController
          before_action :find_product, only: [:index, :book]
          before_action :find_variant, only: :book

          # Query available inventory
          def index
            context = SpreeCmCommissioner::InventoryFetcher.call(
              variants: @product.variants,
              params: fetching_param,
              service_type: service_type
            )

            if context.success?
              render json: Spree::V2::Storefront::InventorySerializer.new(context.results || []).serializable_hash
            else
              render_error(context.message, 400)
            end
          end

          # Book inventory
          # Create add to cart, update inventory_unit
          def book
            context = SpreeCmCommissioner::BookingHandler.call(
              variant_id: @variant.id,
              params: booking_param,
              service_type: service_type
            )

            if context.success?
              # TODO: Add to cart (simplified; integrate with Spree::Order as needed)
              # cart_service = Spree::CartService.new(order: current_order)
              # cart_service.add(variant.id, quantity, booking_params(service_type))
              # render json: { message: "Booking successful", order_id: current_order.id }, status: :created
              render json: { message: "Booking successful" }, status: :created
            else
              render_error(context.message, 422)
            end
          end

          private

          # Inventory query
          def fetching_param
            params.permit(:trip_date, :check_in, :check_out, :num_guests)
          end

          # Booking query
          def booking_param
            params.permit(:trip_date, :check_in, :check_out, :quanity)
          end

          def service_type
            params[:service_type]
          end

          def find_product
            @product = Spree::Product.find_by!(id: params[:product_id])
          end

          def find_variant
            @variant = @product.variants.find(params[:variant_id])
          end

          def render_error(message, status)
            render json: { error: message }, status: status
          end
        end
      end
    end
  end
end
