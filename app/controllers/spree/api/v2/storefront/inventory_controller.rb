# app/controllers/spree/api/v2/inventory_controller.rb
module Spree
  module Api
    module V2
      module Storefront
        class InventoryController < ::Spree::Api::V2::ResourceController
          before_action :find_product, only: [:index, :book]

          # Query available inventory
          def index
            variants = @product.variants
            results = case service_type
                      when "event"
                        variants.map { |v| fetch_event_inventory(v.id) }
                      when "bus"
                        trip_date = Date.parse(params[:trip_date])
                        variants.map { |v| fetch_bus_inventory(v.id, trip_date) }
                      when "accommodation"
                        check_in = Date.parse(params[:check_in])
                        check_out = Date.parse(params[:check_out])
                        num_guests = params[:num_guests].to_i
                        variants.map { |v| fetch_accommodation_inventory(v.id, check_in, check_out, num_guests) }.compact
                      else
                        render_error("Invalid service_type", 400) and return
                      end

            render json: results
          end

          private

          # Inventory query
          def fetch_event_inventory(variant_id)
            SpreeCmCommissioner::InventoryServices::EventService.new(variant_id).fetch_inventory
          end

          def fetch_bus_inventory(variant_id, trip_date)
            SpreeCmCommissioner::InventoryServices::BusService.new(variant_id).fetch_inventory(trip_date)
          end

          def fetch_accommodation_inventory(variant_id, check_in, check_out, num_guests)
            SpreeCmCommissioner::InventoryServices::AccommodationService.new(variant_id).fetch_inventory(check_in, check_out, num_guests)
          end

          def service_type
            @service_type ||= @product.service_type
          end

          def find_product
            @product = Spree::Product.find_by!(id: params[:product_id])
          end

          def render_error(message, status)
            render json: { error: message }, status: status
          end
        end
      end
    end
  end
end
