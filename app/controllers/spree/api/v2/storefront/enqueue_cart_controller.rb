require 'google/cloud/firestore'

module Spree
  module Api
    module V2
      module Storefront
        class EnqueueCartController < CartController
          # override
          def add_item
            spree_authorize! :update, spree_current_order, order_token
            spree_authorize! :show, @variant

            job = SpreeCmCommissioner::Cart::AddItemJob.perform_later(
              spree_current_order.id,
              @variant.id,
              add_item_params[:quantity],
              add_item_params[:public_metadata],
              add_item_params[:private_metadata],
              add_item_params[:options]
            )

            SpreeCmCommissioner::Cart::AddItemStatusMarker.call(
              order_number: spree_current_order.number,
              job_id: job.job_id,
              status: 'processing',
              queued_at: Time.current
            )

            struct = Struct.new(:id, :status, :queued_at)
            firestore_object = firestore_object(job.job_id)

            render_serialized_payload do
              serialize_resource(
                struct.new(id, firestore_object[:status], firestore_object[:queued_at])
              )
            end
          end

          def id
            SecureRandom.hex
          end

          def firestore_object(job_id)
            firestore.col('queues').doc('cart').col(spree_current_order.number).doc(job_id).get
          end

          def firestore
            @firestore ||= Google::Cloud::Firestore.new(project_id: service_account[:project_id], credentials: service_account)
          end

          def service_account
            @service_account ||= Rails.application.credentials.cloud_firestore_service_account
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
