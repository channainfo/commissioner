module Spree
  module Api
    module V2
      module Storefront
        module QueueCart
          class LineItemsController < CartController
            before_action :ensure_order, only: :create
            before_action :load_variant, only: :create
            before_action :ensure_cart_exist, only: :create

            # override
            def create
              spree_authorize! :update, spree_current_order, order_token
              spree_authorize! :show, @variant

              job = SpreeCmCommissioner::EnqueueCart::AddItemJob.perform_later(
                spree_current_order.id,
                @variant.id,
                add_item_params[:quantity],
                add_item_params[:public_metadata],
                add_item_params[:private_metadata],
                add_item_params[:options]
              )

              result = SpreeCmCommissioner::EnqueueCart::AddItemStatusMarker.call(
                order_number: spree_current_order.number,
                job_id: job.job_id,
                status: 'processing',
                queued_at: Time.current,
                variant_id: @variant.id,
                quantity: add_item_params[:quantity]
              )

              line_item_queue = SpreeCmCommissioner::QueueItem.new(
                id: job.job_id,
                status: result.firestore_status,
                queued_at: result.firestore_queued_at,
                collection_reference: result.firestore_collection_reference,
                document_reference: result.firestore_document_reference
              )

              render_serialized_payload do
                serialize_resource(line_item_queue)
              end
            end

            # override
            def resource_serializer
              Spree::V2::Storefront::FirestoreQueueSerializer
            end
          end
        end
      end
    end
  end
end
