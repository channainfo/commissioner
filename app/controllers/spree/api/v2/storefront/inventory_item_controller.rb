# app/controllers/spree/api/v2/inventory_item_controller.rb
module Spree
  module Api
    module V2
      module Storefront
        class InventoryItemController < ::Spree::Api::V2::ResourceController
          before_action :validate_inventory_fetcher, only: [:index]

          def collection
            Kaminari.paginate_array(@context.results)
          end

          def collection_serializer
            Spree::V2::Storefront::InventorySerializer
          end

          # Overwrite cache key
          def collection_cache_key(collection)
            ids = collection.to_a.collect(&:variant_id)
            cache_key_parts = [
              self.class.to_s,
              ids,
              params[:variant_ids]&.sort&.join('-')&.strip,
              params[:trip_date]&.to_s&.strip,
              params[:checkin]&.to_s&.strip,
              params[:checkout]&.to_s&.strip,
              params[:num_guests]&.to_s&.strip,
              params[:product_type]&.to_s&.strip,
              resource_includes,
              sparse_fields,
              serializer_params,
              params[:sort]&.strip,
              params[:page]&.to_s&.strip,
              params[:per_page]&.to_s&.strip,
            ].flatten.join('-')

            Digest::MD5.hexdigest(cache_key_parts)
          end

          # Overwrite cache duration from 1h to 5mn
          def collection_cache_opts
            {
              namespace: Spree::Api::Config[:api_v2_collection_cache_namespace],
              expires_in: 5.minutes.to_i
            }
          end

          private

          # Inventory query
          def fetching_param
            params.permit(:trip_date, :check_in, :check_out, :num_guests)
          end

          def render_error(message, status)
            render json: { error: message }, status: status
          end

          def validate_inventory_fetcher
            @context = SpreeCmCommissioner::InventoryFetcher.call(
              variant_ids: params[:variant_ids],
              params: fetching_param,
              product_type: product_type
            )

            unless @context.success?
              render_error(@context.message, :unprocessable_entity)
              return # This stops the action chain
            end
          end

          def product_type
            params[:product_type]
          end
        end
      end
    end
  end
end
